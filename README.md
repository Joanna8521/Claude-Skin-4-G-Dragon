# Claude Skin

Claude Code 的 skin 系統。換掉 session 的**開場畫面與招呼語**，一行指令切換，一行指令還原。語氣人格是可選的附加層，預設不啟用。

這是 [Codex Dream Skin](https://github.com/Fei-Away/Codex-Dream-Skin) 的 Claude 對等品，但走的路不一樣，原因見下面〈為什麼不是底圖〉。

```bash
./install.sh
```

裝完開新 session 或 `/clear`，開場會變成這樣：

```
                    ♛
   ██████╗ ██████╗
  ██╔════╝ ██╔══██╗
  ██║  ███╗██║  ██║
  ██║   ██║██║  ██║
  ╚██████╔╝██████╔╝
   ╚═════╝ ╚═════╝
  ─────────────────────────────
  欸欸欸這麼晚還沒睡？！歐巴真的會心疼的呦～～～
```

## 指令

```bash
claude-skin list              # 列出所有 skin
claude-skin preview gd-oppa   # 不改設定，直接看開場長怎樣
claude-skin apply gd-oppa     # 套用（只換開場畫面）
claude-skin current           # 看目前套哪個
claude-skin restore           # 還原成套用前的樣子
```

`apply` 和 `restore` 都要開新 session 或 `/clear` 才生效。

想連 Claude 的講話語氣一起換，加旗標：

```bash
claude-skin apply gd-oppa --with-persona
```

**預設不加。** 不加就完全不碰 `outputStyle`，Claude 講話方式一如往常，只有開場畫面變了。

## 一個 skin 有什麼

```
skins/gd-oppa/
├── skin.json        # 名稱、描述、配色
├── banner.sh        # 開場畫面（SessionStart hook）
├── greetings.txt    # 招呼語庫，依時段分組
└── persona.md       # 人格（可選，--with-persona 才裝）
```

**banner.sh** 掛在 `SessionStart` hook，`matcher` 是 `startup|clear`，所以開新 session 和 `/clear` 都會出現。這是少數 stdout 會**直接顯示給使用者**的 hook，其他 hook 的 stdout 只進 debug log。

招呼語依當下時段從 `greetings.txt` 隨機挑，所以每次開場不一樣：

| 時段 | 時間 |
|---|---|
| `morning` | 05:00 – 11:00 |
| `afternoon` | 11:00 – 18:00 |
| `night` | 18:00 – 23:00 |
| `latenight` | 23:00 – 05:00 |
| `any` | 任何時候都可能抽到 |

要改句子直接編 `greetings.txt`，格式 `時段|句子`，`#` 開頭是註解。改完立刻生效，不用重新 apply。

### 可選的人格層

`persona.md` 是 Claude Code 的 output style，只有 `--with-persona` 才會裝。裡面寫死一條線：測試掛了就說掛了、沒做完就說沒做完、不確定就說不確定。壞消息可以用可愛的語氣講，但不准為了哄人而修飾內容。

一個會說「差不多好了呦～」但其實測試全紅的 AI 比沒有人格的 AI 危險得多。要自己寫人格檔的話請保留這段。

## 自己做一個 skin

複製 `skins/gd-oppa/` 改名，四個檔案照著改：

- `skin.json` 的 `name` 要和資料夾同名
- `banner.sh` 隨便你印什麼，記得 `exit 0`
- 支援兩個環境變數：`CLAUDE_SKIN_COLOR=1` 開色、`CLAUDE_SKIN_QUIET=1` 只印一行
- `persona.md` 可以不要。要的話 frontmatter 的 `name` 就是 `/config` 裡看到的 output style 名稱

然後 `claude-skin apply <你的名字>`。

## 為什麼不是底圖

Codex Dream Skin 的做法是用本機 CDP 連進 Codex 桌面 app，注入 CSS 把整個視窗換成一張圖。**這條路在 Claude 上是封死的。**

Claude.app（Electron 42.7.0）的 main process 有一段啟動參數守衛：

```js
A.some(g => {
  const I = g.replace(/^(?:--|-|\/)/, "").toLowerCase();
  return I.startsWith("remote-debugging-port") || I.startsWith("remote-debugging-pipe")
})
```

實測用 `--remote-debugging-port=9223` 啟動（獨立 `--user-data-dir`），程序立刻結束、exit 0、無視窗、port 無監聽。

這是刻意的安全控制，理由很硬：CDP 一開，任何本機程序都能讀你的 session token、對話內容、MCP 憑證。Codex 沒擋所以 Dream Skin 能用，Claude 擋了。

繞過去唯一的辦法是改 `app.asar` 或重簽 binary，那會破壞 code signature、每次更新被覆蓋、而且把帳號憑證暴露給整台機器。**本專案不做這件事**，所以改走官方支援的 hook + output style，換來的是升級不會壞、憑證不外洩。

順帶一提，Dream Skin 自己的 README 也強調「不修改 .app、不動 app.asar、不破壞簽章」。差別只在 Codex 留了 CDP 這扇門，Claude 沒有。

## 適用範圍

| 目標 | 支援 |
|---|---|
| 桌面 app 的 Code 分頁 | ✅ |
| 終端機的 `claude` CLI | ✅ |
| 桌面 app 的 Chat 分頁 | ❌ 沒有 hook 系統 |
| app 視窗底圖／自訂 CSS | ❌ 見上一節 |

顏色主題只能從 `settings.json` 的 `theme` 挑內建值，沒有自訂 theme 檔的機制。

`CLAUDE_SKIN_COLOR` 預設關閉，因為 hook 的 stdout 一定是 pipe 不是 TTY，腳本無從偵測對方吃不吃 ANSI。開起來若看到跳脫字元，關掉即可。

## 動到哪些檔案

```
~/.claude/settings.json                     加 outputStyle 與 hooks.SessionStart
~/.claude/settings.json.pre-skin-<時間戳>    首次套用前的完整備份
~/.claude/output-styles/<skin>.md           複製進去的人格檔
~/.claude/claude-skin-state.json            記錄原狀，restore 用
```

`restore` 只移除本工具加的東西，不會動你原本的設定。備份檔會留著不刪。

## 說明

GD 歐巴是粉絲向的應援角色設定，與權志龍本人及其經紀公司無關，也不代表他發言。自己用開心就好，不要拿去當作官方或本人背書的東西發布。
