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

# --- optional KOSPI/ticker line (NEWSLINE_STOCK=on) — own cache/TTL, own lock,
# so it never waits on (or blocks) the news refresh above ---
stock_enabled() {
  case "$(printf '%s' "${NEWSLINE_STOCK:-}" | tr '[:upper:]' '[:lower:]')" in
    on|yes|1|true) return 0 ;;
    *) return 1 ;;
  esac
}
# KRX cash session (09:00-15:30), local wall clock — outside this window we never
# hit the API; the last fetched line (i.e. the 15:30 close) just stays on screen as-is.
# Test overrides: NEWSLINE_STOCK_HOUR / NEWSLINE_STOCK_MINUTE force the clock.
stock_market_hours() {
  local h="${NEWSLINE_STOCK_HOUR:-$(date +%H)}" m="${NEWSLINE_STOCK_MINUTE:-$(date +%M)}"
  local mins=$((10#$h * 60 + 10#$m))
  [ "$mins" -ge $((9 * 60)) ] && [ "$mins" -lt $((15 * 60 + 30)) ]
}
STOCK_FILE="$CACHE_DIR/stock.line"
if stock_enabled && stock_market_hours; then
  STOCK_TTL="${NEWSLINE_STOCK_TTL:-30}"       # prices move faster than headlines
  stock_needs_refresh=1
  if [ -f "$STOCK_FILE" ]; then
    now=$(date +%s)
    smtime=$(stat -f %m "$STOCK_FILE" 2>/dev/null || stat -c %Y "$STOCK_FILE" 2>/dev/null || echo 0)
    [ $((now - smtime)) -lt "$STOCK_TTL" ] && stock_needs_refresh=0
  fi
  if [ "$stock_needs_refresh" = "1" ]; then
    ( "$HERE/refresh_stock.sh" >/dev/null 2>&1 & ) 2>/dev/null
  fi
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

# --- per-terminal click hint, printed dim before the headline, e.g. "(Cmd+Click)" ---
# Headlines are OSC 8 hyperlinks; WHICH modifier opens them is the terminal's call,
# not ours (macOS terminals use Cmd, most others Ctrl, kitty Ctrl+Shift). Show the
# right one so users know how to click through. NEWSLINE_CLICKHINT: unset/auto/on =
# auto-detect; off/none/0 = hide; any other value is used verbatim (e.g. "⌘-click").
click_hint() {
  case "$(printf '%s' "${NEWSLINE_CLICKHINT:-}" | tr '[:upper:]' '[:lower:]')" in
    off|none|no|0|false) return 0 ;;                                      # hidden
    ''|auto|on|yes|1|true) ;;                                             # auto-detect
    *) printf '\033[90m(%s)\033[0m ' "$NEWSLINE_CLICKHINT"; return 0 ;;   # custom label
  esac
  local sys="${OSTYPE:-}"; [ -n "$sys" ] || sys="$(uname -s 2>/dev/null)"
  local mod; case "$sys" in [Dd]arwin*) mod="Cmd+Click" ;; *) mod="Ctrl+Click" ;; esac
  { [ -n "${KITTY_WINDOW_ID:-}" ] || [ "${TERM:-}" = "xterm-kitty" ]; } && mod="Ctrl+Shift+Click"
  printf '\033[90m(%s)\033[0m ' "$mod"
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
    click_hint                            # "(Cmd+Click)" etc., before the linked headline
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

# --- optional KOSPI/ticker line, printed below news + notice ---
if stock_enabled && [ -s "$STOCK_FILE" ]; then
  { [ -s "$CACHE_FILE" ] || [ -s "$NOTICE_FILE" ]; } || printf '\n'
  cat "$STOCK_FILE"
fi
