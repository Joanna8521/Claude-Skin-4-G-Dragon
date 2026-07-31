#!/bin/bash
# 把 claude-skin 指令裝進 PATH，然後套用預設 skin。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DST="${CLAUDE_SKIN_BIN:-$HOME/.local/bin}"
DEFAULT_SKIN="${1:-gd-oppa}"

mkdir -p "$BIN_DST"
chmod +x "$REPO/bin/claude-skin" "$REPO"/skins/*/banner.sh
ln -sf "$REPO/bin/claude-skin" "$BIN_DST/claude-skin"

echo "✓ claude-skin → $BIN_DST/claude-skin"

case ":$PATH:" in
  *":$BIN_DST:"*) ;;
  *)
    echo
    echo "注意：$BIN_DST 不在 PATH 裡，加這行到 ~/.zshrc："
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

echo
"$REPO/bin/claude-skin" apply "$DEFAULT_SKIN"
