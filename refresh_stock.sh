#!/usr/bin/env bash
# newsline · stock background refresh — mirrors refresh.sh's lock/atomic-write
# pattern exactly, but on its OWN lock + cache file + TTL. Prices need a much
# shorter refresh cadence than news, and a slow news fetch must never delay a
# price update (or vice versa) — so the two never share a lock.
#
# Safe to run detached (statusline.sh backgrounds it) or standalone for tests:
#   ./refresh_stock.sh && cat ~/.cache/newsline/stock.line
#
# Only dependency: python3 (stdlib urllib — no curl, no API key, no server).

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${NEWSLINE_CACHE:-$HOME/.cache/newsline}"
CACHE_FILE="$CACHE_DIR/stock.line"
CODES="${NEWSLINE_STOCK_CODES:-005930,000660}"
LOCK="$CACHE_DIR/refresh_stock.lock"
mkdir -p "$CACHE_DIR" 2>/dev/null

# --- single-flight: same stale-lock expiry as refresh.sh ---
if [ -d "$LOCK" ]; then
  now=$(date +%s)
  lmt=$(stat -f %m "$LOCK" 2>/dev/null || stat -c %Y "$LOCK" 2>/dev/null || echo 0)
  [ $((now - lmt)) -gt 120 ] && rmdir "$LOCK" 2>/dev/null
fi
if ! mkdir "$LOCK" 2>/dev/null; then exit 0; fi
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

# Tell fetch_stock.py whether we already have a line cached — on a closed
# market (holiday/weekend/off-hours) with nothing cached yet it still builds
# a full line from the last real data; with a cache already in place it can
# skip straight past the extra top5 lookup (see fetch_stock.py).
has_cache=0; [ -s "$CACHE_FILE" ] && has_cache=1

# --- fetch + parse + build the line; write atomically, keep old cache on failure ---
if NEWSLINE_STOCK_HAS_CACHE="$has_cache" python3 "$HERE/fetch_stock.py" "$CODES" > "$CACHE_FILE.tmp" 2>/dev/null \
   && [ -s "$CACHE_FILE.tmp" ]; then
  mv -f "$CACHE_FILE.tmp" "$CACHE_FILE"
else
  rm -f "$CACHE_FILE.tmp" 2>/dev/null
fi
