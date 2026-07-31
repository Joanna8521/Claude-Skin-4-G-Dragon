#!/bin/bash
# 把 claude-skin 裝進 PATH，套用預設 skin，然後告訴你下一步做什麼。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DST="${CLAUDE_SKIN_BIN:-$HOME/.local/bin}"
DEFAULT_SKIN="${1:-gd-oppa}"

# ---------- 環境檢查 ----------
if [ "$(uname)" != "Darwin" ]; then
  echo "錯誤：目前只支援 macOS，圖片轉檔用的是系統內建的 sips。" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "錯誤：找不到 python3。macOS 內建應該有，可以先跑 xcode-select --install。" >&2
  exit 1
fi

if [ ! -d "$REPO/skins/$DEFAULT_SKIN" ]; then
  echo "錯誤：找不到 skin「$DEFAULT_SKIN」。" >&2
  echo "可用的：$(ls "$REPO/skins" 2>/dev/null | tr '\n' ' ')" >&2
  exit 1
fi

# ---------- 安裝 ----------
mkdir -p "$BIN_DST"
chmod +x "$REPO"/bin/*
ln -sf "$REPO/bin/claude-skin" "$BIN_DST/claude-skin"
echo "✓ claude-skin → $BIN_DST/claude-skin"

echo
"$REPO/bin/claude-skin" apply "$DEFAULT_SKIN"

# ---------- PATH 提醒 ----------
IN_PATH=1
case ":$PATH:" in
  *":$BIN_DST:"*) ;;
  *) IN_PATH=0 ;;
esac

echo
echo "────────────────────────────────────────"
echo "接下來"
echo "────────────────────────────────────────"

STEP=1
if [ "$IN_PATH" = "0" ]; then
  echo
  echo "$STEP. 把 $BIN_DST 加進 PATH，然後重開終端機："
  echo
  echo "     echo 'export PATH=\"$BIN_DST:\$PATH\"' >> ~/.zshrc"
  echo
  STEP=$((STEP + 1))
fi

cat <<EOF

$STEP. 放你自己的照片（repo 沒有附）。先開裁切工具，拖出你要的範圍，
   複製它給的指令貼回終端機：

     claude-skin crop ~/Pictures/你的照片.jpg

   懶得裁的話直接：claude-skin photo ~/Pictures/你的照片.jpg

$((STEP + 1)). 開一個新對話，隨便說一句話。問候會出現在回覆最上面。

想改句子：
  claude-skin add "想聽的話"      加進隨機池，永久留著
  claude-skin say "今天的目標"     只有今天，會蓋掉隨機池

不想要了：claude-skin restore   會清掉所有東西，包含放進各專案的照片副本

完整說明看 README.md
EOF
