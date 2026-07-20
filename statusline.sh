#!/usr/bin/env bash
# newsline · statusLine entry — MUST stay fast. Prints the cached headline
# instantly and, if the cache is stale, kicks off a DETACHED background
# refresh. It never fetches in the foreground, so the status line never lags.
#
# Wire it into ~/.claude/settings.json via settings.snippet.json.

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${NEWSLINE_CACHE:-$HOME/.cache/newsline}"
CACHE_FILE="$CACHE_DIR/line"
TTL="${NEWSLINE_TTL:-900}"          # refresh cache older than this many seconds
mkdir -p "$CACHE_DIR" 2>/dev/null

# --- decide whether a refresh is due (missing or older than TTL) ---
needs_refresh=1
if [ -f "$CACHE_FILE" ]; then
  now=$(date +%s)
  mtime=$(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
  if [ $((now - mtime)) -lt "$TTL" ]; then needs_refresh=0; fi
fi

# --- fire-and-forget background refresh; never block the status line ---
if [ "$needs_refresh" = "1" ]; then
  ( "$HERE/refresh.sh" >/dev/null 2>&1 & ) 2>/dev/null
fi

# --- optional headline color (NEWSLINE_COLOR: a name, or raw SGR params) ---
# Applied at PRINT time, not baked into the cache, so `newsline color` shows up
# on the next status-line tick without waiting for a refresh.
SGR=""
case "$(printf '%s' "${NEWSLINE_COLOR:-}" | tr '[:upper:]' '[:lower:]')" in
  ''|default|none|off) SGR="" ;;
  dim)        SGR="2"  ;;
  gray|grey)  SGR="90" ;;
  red)        SGR="31" ;;  green)   SGR="32" ;;  yellow) SGR="33" ;;
  blue)       SGR="34" ;;  magenta) SGR="35" ;;  cyan)   SGR="36" ;;
  white)      SGR="37" ;;  orange)  SGR="38;5;208" ;;
  *[!0-9\;]*) SGR="" ;;                  # unknown name — ignore, print plain
  *)          SGR="${NEWSLINE_COLOR}" ;; # raw SGR params, e.g. "38;5;245"
esac
colorize() { # wrap text in the configured color (no-op when unset); no newline
  if [ -n "$SGR" ]; then printf '\033[%sm%s\033[0m' "$SGR" "$1"; else printf '%s' "$1"; fi
}

# --- print one headline, rotating across the cached set by wall-clock time ---
# The cache holds N headlines (one per line). We show a different one every
# NEWSLINE_ROTATE seconds — a ticker feel with zero stored state.
if [ -s "$CACHE_FILE" ]; then
  n=$(awk 'END{print NR}' "$CACHE_FILE" 2>/dev/null)
  if [ "${n:-0}" -gt 0 ] 2>/dev/null; then
    rot="${NEWSLINE_ROTATE:-6}"          # seconds each headline stays up
    case "$rot" in ''|*[!0-9]*) rot=6 ;; esac
    [ "$rot" -ge 1 ] || rot=6            # 0 would divide by zero below
    now="${NEWSLINE_NOW:-$(date +%s)}"   # NEWSLINE_NOW overrides clock (tests/debug)
    idx=$(( (now / rot) % n + 1 ))
    colorize "$(sed -n "${idx}p" "$CACHE_FILE")"; printf '\n'
  else
    colorize '📰 …'
  fi
else
  colorize '📰 …'   # first run, before the first refresh lands
fi

# --- server-driven update nudge (written/cleared by refresh.sh), below the news ---
NOTICE_FILE="$CACHE_DIR/notice"
if [ -s "$NOTICE_FILE" ]; then
  [ -s "$CACHE_FILE" ] || printf '\n'   # placeholder path prints without a newline
  head -1 "$NOTICE_FILE"
fi
