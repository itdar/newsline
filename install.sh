#!/usr/bin/env sh
# newsline · installer — works from a local checkout OR piped from the web:
#     ./install.sh
#     curl -fsSL https://raw.githubusercontent.com/itdar/cc-plugin/master/install.sh | sh
# No build step; copies the scripts onto your PATH. Idempotent (safe to re-run).
set -eu

REPO="${NEWSLINE_REPO:-itdar/cc-plugin}"
REF="${NEWSLINE_REF:-master}"
PREFIX="${NEWSLINE_PREFIX:-$HOME/.local}"
SHARE="$PREFIX/share/newsline"
BIN="$PREFIX/bin"
FILES="newsline statusline.sh refresh.sh fetch.py resolve.py feeds.json"

command -v python3 >/dev/null 2>&1 || { echo "✗ newsline needs python3 (not found)"; exit 1; }

# Source = a local checkout ONLY when actually run as ./install.sh; else (curl|sh) download.
SELFDIR=""
case "$0" in */install.sh|install.sh) SELFDIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd -P || true)" ;; esac
if [ -n "$SELFDIR" ] && [ -f "$SELFDIR/newsline" ] && [ -f "$SELFDIR/fetch.py" ]; then
  SRCDIR="$SELFDIR"
else
  command -v curl >/dev/null 2>&1 || { echo "✗ curl required to download"; exit 1; }
  TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
  echo "↓ downloading $REPO@$REF …"
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/$REF.tar.gz" | tar -xz -C "$TMP"
  SRCDIR="$(find "$TMP" -maxdepth 1 -mindepth 1 -type d | head -1)"
fi

mkdir -p "$SHARE" "$BIN"
for f in $FILES; do cp "$SRCDIR/$f" "$SHARE/$f"; done
chmod +x "$SHARE/newsline" "$SHARE/statusline.sh" "$SHARE/refresh.sh"
ln -sf "$SHARE/newsline" "$BIN/newsline"

echo "✔ installed: $BIN/newsline"

# Register $BIN on PATH for future shells (idempotent), by shell rc file.
case ":$PATH:" in
  *":$BIN:"*)
    :
    ;;
  *)
    case "$(basename "${SHELL:-sh}")" in
      zsh)  rc="$HOME/.zshrc"  ; line="export PATH=\"$BIN:\$PATH\"" ;;
      bash) rc="$HOME/.bashrc" ; line="export PATH=\"$BIN:\$PATH\"" ;;
      fish) rc="$HOME/.config/fish/config.fish" ; line="fish_add_path \"$BIN\"" ;;
      *)    rc="$HOME/.profile" ; line="export PATH=\"$BIN:\$PATH\"" ;;
    esac
    mkdir -p "$(dirname "$rc")"
    if [ -f "$rc" ] && grep -qF "$BIN" "$rc" 2>/dev/null; then
      echo "✔ PATH already configured in $rc"
    else
      printf '\n# added by newsline installer\n%s\n' "$line" >> "$rc"
      echo "✔ added $BIN to PATH in $rc"
    fi
    echo
    echo "→ apply to THIS shell now:   source $rc"
    echo "  (new terminals apply it automatically)"
    ;;
esac

# Auto-setup: run init now (prompts via the terminal even under curl|sh) unless
# disabled (NEWSLINE_NO_INIT=1) or there is no terminal to prompt from.
if [ "${NEWSLINE_NO_INIT:-}" != "1" ] && { [ -t 0 ] || [ -r /dev/tty ]; }; then
  echo
  "$BIN/newsline" init
else
  echo "next:  newsline init"
fi
