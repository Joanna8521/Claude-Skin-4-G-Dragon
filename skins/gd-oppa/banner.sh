#!/bin/bash
# SessionStart hook: 印出 GD 歐巴開場畫面。
# stdout 會同時顯示給使用者、並注入 Claude 的 context（見 Claude Code hooks 文件）。
#
# 環境變數：
#   CLAUDE_SKIN_COLOR=1  啟用 ANSI 256 色（預設關閉，避免終端機不支援時噴出跳脫字元）
#   CLAUDE_SKIN_QUIET=1  只印一行問候，不印 ASCII 大圖

set -uo pipefail

SKIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREETINGS="$SKIN_DIR/greetings.txt"

# ---------- 配色 ----------
if [ "${CLAUDE_SKIN_COLOR:-0}" = "1" ]; then
  A=$'\033[38;5;204m'   # 桃粉
  D=$'\033[38;5;138m'   # 灰粉
  R=$'\033[0m'
  B=$'\033[1m'
else
  A=""; D=""; R=""; B=""
fi

# ---------- 依時段挑句子 ----------
hour=$(date +%-H)
if   [ "$hour" -ge 5 ]  && [ "$hour" -lt 11 ]; then slot="morning"
elif [ "$hour" -ge 11 ] && [ "$hour" -lt 18 ]; then slot="afternoon"
elif [ "$hour" -ge 18 ] && [ "$hour" -lt 23 ]; then slot="night"
else slot="latenight"
fi

greeting=""
if [ -r "$GREETINGS" ]; then
  # 取該時段 + any 的句子，隨機挑一句
  greeting=$(grep -v '^\s*#' "$GREETINGS" \
    | grep -E "^(${slot}|any)\|" \
    | sed 's/^[^|]*|//' \
    | grep -v '^\s*$' \
    | sort -R 2>/dev/null | head -1)
fi
[ -z "$greeting" ] && greeting="今天也要加油喔！不要太累了呦～～～歐巴會心疼的呢！"

# ---------- 輸出 ----------
if [ "${CLAUDE_SKIN_QUIET:-0}" = "1" ]; then
  printf '%s\n' "${A}👑 GD 歐巴${R}：${greeting}"
else
  cat <<EOF
${A}                    ♛
   ██████╗ ██████╗
  ██╔════╝ ██╔══██╗
  ██║  ███╗██║  ██║
  ██║   ██║██║  ██║
  ╚██████╔╝██████╔╝
   ╚═════╝ ╚═════╝${R}
${D}  ─────────────────────────────${R}
EOF
  printf '  %s%s%s\n' "$B$A" "$greeting" "$R"
fi

exit 0
