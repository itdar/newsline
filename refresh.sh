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
# Client version, sent to /feed as ?v= for the server-side update nudge.
# Bump together with package.json when tagging a release.
export NEWSLINE_VERSION="${NEWSLINE_VERSION:-0.1.4}"
LOCK="$CACHE_DIR/refresh.lock"
mkdir -p "$CACHE_DIR" 2>/dev/null

# --- single-flight: if another refresh is already running, bail quietly ---
# A refresh killed before its EXIT trap runs (SIGKILL, reboot, closed terminal)
# leaves the lock behind; expire locks older than 120s so refreshes never wedge.
if [ -d "$LOCK" ]; then
  now=$(date +%s)
  lmt=$(stat -f %m "$LOCK" 2>/dev/null || stat -c %Y "$LOCK" 2>/dev/null || echo 0)
  [ $((now - lmt)) -gt 120 ] && rmdir "$LOCK" 2>/dev/null
fi
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
# The resolved list is reused for NEWSLINE_API_TTL seconds (feed curation changes
# rarely) so the curation API is hit at most hourly, not on every refresh.
RESOLVED="$CACHE_DIR/feeds.resolved.json"
RESOLVE_STAMP="$CACHE_DIR/feeds.resolved.ok"
RESOLVE_TTL="${NEWSLINE_API_TTL:-3600}"
export NEWSLINE_COUNTRY="$country"
export NEWSLINE_LOCALTIME="$(date +%H%M)"
export NEWSLINE_DOW="$(date +%u)"
export NEWSLINE_TZ="$(date +%z)"
need_resolve=1
if [ -s "$RESOLVED" ] && [ -f "$RESOLVE_STAMP" ]; then
  now=$(date +%s)
  smt=$(stat -f %m "$RESOLVE_STAMP" 2>/dev/null || stat -c %Y "$RESOLVE_STAMP" 2>/dev/null || echo 0)
  [ $((now - smt)) -lt "$RESOLVE_TTL" ] && need_resolve=0
fi
if [ "$need_resolve" = "1" ]; then
  if python3 "$HERE/resolve.py" "$lang" "$FEEDS" "${NEWSLINE_API:-https://newsline.thesockerrr.workers.dev}" > "$RESOLVED.tmp" 2>/dev/null \
     && [ -s "$RESOLVED.tmp" ]; then
    mv -f "$RESOLVED.tmp" "$RESOLVED"
    touch "$RESOLVE_STAMP"
  else
    rm -f "$RESOLVED.tmp" 2>/dev/null
    [ -s "$RESOLVED" ] || cp "$FEEDS" "$RESOLVED" 2>/dev/null   # last-ditch fallback to bundled feeds
  fi
fi

# --- server-driven update nudge: one extra line below the news --------------
# If the server flagged this client as too old (RESOLVED has "_update"),
# write the notice line statusline.sh appends; otherwise clear it. Skipped
# (cleared) when this client already meets minVersion, so the nudge stops
# right after an update even while the old RESOLVED is still cached.
NOTICE="$CACHE_DIR/notice"
msg=$(python3 -c '
import json, os, sys
try:
    u = json.load(open(sys.argv[1])).get("_update") or {}
except Exception:
    u = {}
def pv(s): return [int(x) if x.isdigit() else 0 for x in str(s).split(".")]
mv, cur = u.get("minVersion", ""), os.environ.get("NEWSLINE_VERSION", "")
print("" if (mv and cur and pv(cur) >= pv(mv)) else u.get("message", ""))
' "$RESOLVED" 2>/dev/null | tr -d '\000-\037')
if [ -n "$msg" ]; then
  case "$HERE" in                      # install channel by where we live
    *"/node_modules/"*)      ucmd="npm i -g newsline-cli" ;;
    *[Cc]ellar*|*linuxbrew*) ucmd="brew upgrade newsline" ;;
    *) ucmd="curl -fsSL https://raw.githubusercontent.com/itdar/cc-plugin/master/install.sh | sh" ;;
  esac
  # yellow line, command in bold bright yellow — mirrors Claude Code's own update nudge
  printf '\033[33m[%s] Run: \033[1;93m%s\033[0m\n' "$msg" "$ucmd" > "$NOTICE.tmp" && mv -f "$NOTICE.tmp" "$NOTICE"
else
  rm -f "$NOTICE" 2>/dev/null
fi

# --- fetch + parse + build the line; write atomically, keep old cache on failure ---
if python3 "$HERE/fetch.py" "$lang" "$RESOLVED" "$ENDPOINT" "$COUNT" > "$CACHE_DIR/line.tmp" 2>/dev/null \
   && [ -s "$CACHE_DIR/line.tmp" ]; then
  mv -f "$CACHE_DIR/line.tmp" "$CACHE_FILE"
else
  rm -f "$CACHE_DIR/line.tmp" 2>/dev/null   # graceful fallback: previous cache stays
fi
