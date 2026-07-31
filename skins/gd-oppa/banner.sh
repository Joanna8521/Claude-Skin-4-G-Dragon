#!/bin/bash
# SessionStart hook：印出開場畫面（左邊照片、右邊打氣話）。
# stdout 會同時顯示給使用者、並注入 Claude 的 context（見 Claude Code hooks 文件）。
#
# 環境變數：
#   CLAUDE_SKIN_COLOR=0  關掉顏色，照片欄會略過
#   CLAUDE_SKIN_QUIET=1  只印一行字

set -uo pipefail

SKIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RENDER="$(cd "$SKIN_DIR/../../bin" && pwd)/render-banner"

if [ -x "$RENDER" ]; then
  python3 "$RENDER" "$SKIN_DIR" || true
fi

exit 0
