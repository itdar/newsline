#!/usr/bin/env bash
# newsline · background refresh — detects locale, fetches a keyless regional
# RSS feed LOCALLY, parses the top headline, and atomically writes the
# ready-to-print status line (with an OSC 8 click link) to the cache.
#
# Safe to run detached (statusline.sh backgrounds it) or standalone for tests:
#   NEWSLINE_ENDPOINT=http://localhost:8787/r ./refresh.sh && cat ~/.cache/newsline/line
#
# Only dependency: python3 (stdlib urllib — no curl, no API key, no server).

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${NEWSLINE_CACHE:-$HOME/.cache/newsline}"
CACHE_FILE="$CACHE_DIR/line"
FEEDS="${NEWSLINE_FEEDS:-$HERE/feeds.json}"
# The redirect wrapper you control. This is the ONE remote piece — clicks pass
# through it so monetization can be switched on later WITHOUT re-shipping.
ENDPOINT="${NEWSLINE_ENDPOINT:-https://newsline.thesockerrr.workers.dev/r}"
COUNT="${NEWSLINE_COUNT:-15}"         # how many headlines to cache for rotation
LOCK="$CACHE_DIR/refresh.lock"
mkdir -p "$CACHE_DIR" 2>/dev/null

# --- single-flight: if another refresh is already running, bail quietly ---
if ! mkdir "$LOCK" 2>/dev/null; then exit 0; fi
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

# --- detect locale language (region-appropriate news) ---
# priority: explicit NEWSLINE_LANG > macOS system region > locale env vars > en.
# (macOS terminals often have LANG=en_US even for non-US users, so the system
#  region AppleLocale is the truer "where am I" signal for regional news.)
raw="${NEWSLINE_LANG:-}"
if [ -z "$raw" ] && command -v defaults >/dev/null 2>&1; then
  raw="$(defaults read NSGlobalDomain AppleLocale 2>/dev/null)"   # e.g. ko_KR
fi
[ -z "$raw" ] && raw="${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}"
case "$raw" in ""|C|POSIX|C.*|POSIX.*) raw="en_US" ;; esac
lang="${raw%%.*}"    # strip .UTF-8
lang="${lang%%@*}"   # strip @variant
lang="${lang%%_*}"   # strip _REGION
lang="${lang%%-*}"   # strip -Script (e.g. zh-Hans)
[ -z "$lang" ] && lang="en"

# derive coarse country/region from raw (ko_KR -> KR); empty if none
reg="${raw%%.*}"; reg="${reg%%@*}"
case "$reg" in
  *_*) country="${reg#*_}"; country="${country%%-*}" ;;
  *)   country="" ;;
esac

# --- server-first feed selection (COARSE context only), local fallback ---
# resolve.py tries $NEWSLINE_API/feed; on any failure it returns local feeds.json.
# We send lang/country/localtime/dow/tz only — no personal data, no tracking id.
RESOLVED="$CACHE_DIR/feeds.resolved.json"
export NEWSLINE_COUNTRY="$country"
export NEWSLINE_LOCALTIME="$(date +%H%M)"
export NEWSLINE_DOW="$(date +%u)"
export NEWSLINE_TZ="$(date +%z)"
if ! python3 "$HERE/resolve.py" "$lang" "$FEEDS" "${NEWSLINE_API:-https://newsline.thesockerrr.workers.dev}" > "$RESOLVED" 2>/dev/null \
   || [ ! -s "$RESOLVED" ]; then
  cp "$FEEDS" "$RESOLVED" 2>/dev/null   # last-ditch fallback to bundled feeds
fi

# --- fetch + parse + build the line; write atomically, keep old cache on failure ---
if python3 "$HERE/fetch.py" "$lang" "$RESOLVED" "$ENDPOINT" "$COUNT" > "$CACHE_DIR/line.tmp" 2>/dev/null \
   && [ -s "$CACHE_DIR/line.tmp" ]; then
  mv -f "$CACHE_DIR/line.tmp" "$CACHE_FILE"
else
  rm -f "$CACHE_DIR/line.tmp" 2>/dev/null   # graceful fallback: previous cache stays
fi
