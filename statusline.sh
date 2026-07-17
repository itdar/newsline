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
    sed -n "${idx}p" "$CACHE_FILE"
  else
    printf '📰 …'
  fi
else
  printf '📰 …'   # first run, before the first refresh lands
fi
