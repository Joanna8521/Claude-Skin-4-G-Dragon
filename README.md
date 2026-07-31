# Claude Skin

新對話一開始，你的照片和今天想對自己說的話會出現在最上面。

```
  ┌─────────────┐
  │             │   今天想對自己說的話
  │   你的照片   │
  │  （色塊）    │   今天只要把這件事做完就贏了
  │             │
  └─────────────┘
```

左邊是照片轉成的終端機色塊，右邊是招呼語。一行指令切換，一行指令還原。

> **English**: A skin system for Claude Code. Renders your own photo as truecolor
> terminal blocks plus a daily message at the top of every new session, via the
> `SessionStart` hook. macOS only (uses built-in `sips`). No dependencies.
> **The CLI and docs are in Traditional Chinese.**

---

## 安裝

```bash
git clone https://github.com/Joanna8521/Claude-Skin-4-G-Dragon.git
cd Claude-Skin-4-G-Dragon
./install.sh
```

零依賴。縮圖交給 macOS 內建的 `sips`，BMP 解碼和色塊渲染都是 Python 標準庫，不用 `pip install` 也不用 `brew install`。

**repo 沒有附照片**，放你自己的：

```bash
claude-skin photo ~/Downloads/你的圖.jpg -c 400x400+240+129
```

開新對話或 `/clear` 就會看到。

## 照片要裁到臉，這是重點

終端機一個字元格只能塞兩個像素。52 字元寬的圖，實際解析度就是 52×52。

全身照直接丟進去，臉大概只剩十幾個像素，會糊成一團馬賽克。**裁到臉再轉，差別非常大。**

```bash
claude-skin photo <圖> -c WxH+X+Y
```

`X`、`Y` 是裁切框左上角在原圖的座標。用預覽程式或任何看得到座標的工具量一下就好。

尺寸怎麼挑：

| 寬度 | 行高 | 適合 |
|---|---|---|
| 36 | 18 | 最省畫面，只看得出輪廓和配色 |
| **52** | **26** | **預設。認得出五官** |
| 72 | 36 | 最清楚，但會吃掉大半個畫面 |

```bash
claude-skin photo <圖> -w 72 -c 400x400+240+129
```

## 指令

```bash
claude-skin list                  # 列出所有 skin
claude-skin apply <name>          # 套用
claude-skin current               # 看目前套哪個
claude-skin restore               # 還原成套用前的樣子

claude-skin say "今天的話"         # 設定今天想對自己說的話
claude-skin say                   # 看今天設了什麼
claude-skin say --clear           # 清掉，改回隨機招呼語
claude-skin photo <圖> [-w] [-c]  # 換照片
```

`apply` 和 `restore` 要開新 session 或 `/clear` 才生效。`say` 和改 `greetings.txt` 是即時的。

### 每天的話

`claude-skin say` 設的話**只有當天有效**，隔天自動換回隨機招呼語。

沒設的時候，會依當下時段從 `greetings.txt` 隨機挑：

| 時段 | 時間 |
|---|---|
| `morning` | 05:00 – 11:00 |
| `afternoon` | 11:00 – 18:00 |
| `night` | 18:00 – 23:00 |
| `latenight` | 23:00 – 05:00 |
| `any` | 任何時候 |

格式是 `時段|句子`，`#` 開頭是註解。改完存檔立刻生效。

## 一個 skin 有什麼

```
skins/<name>/
├── skin.json        # 名稱、描述
├── banner.sh        # SessionStart hook 進入點
├── greetings.txt    # 招呼語庫
├── art.txt          # 沒照片時的字元畫
├── photo.ansi       # 照片色塊（gitignore，本機才有）
├── today.txt        # 今天的話（gitignore）
└── persona.md       # 人格（可選）
```

要自己做一個，複製一份改名就好，`skin.json` 的 `name` 要和資料夾同名。

## 可選：連語氣一起換

```bash
claude-skin apply <name> --with-persona
```

會把 `persona.md` 裝成 Claude Code 的 output style，改變 Claude 的講話方式。**預設不加**，不加就完全不碰 `outputStyle`。

`persona.md` 裡寫死一條線：測試掛了就說掛了、沒做完就說沒做完、不確定就說不確定。壞消息可以用可愛的語氣講，但不准為了哄人而修飾內容。

一個會說「差不多好了呦～」但其實測試全紅的 AI，比沒有人格的 AI 危險得多。要自己寫人格檔請保留這段。

## 為什麼是開場畫面，不是滿版底圖

[Codex Dream Skin](https://github.com/Fei-Away/Codex-Dream-Skin) 的做法是用本機 CDP 連進 Codex 桌面 app，注入 CSS 把整個視窗換成一張圖。**這條路在 Claude 上是封死的。**

Claude.app（Electron 42.7.0）的 main process 有一段啟動參數守衛：

```js
A.some(g => {
  const I = g.replace(/^(?:--|-|\/)/, "").toLowerCase();
  return I.startsWith("remote-debugging-port") || I.startsWith("remote-debugging-pipe")
})
```

實測用 `--remote-debugging-port=9223` 啟動（獨立 `--user-data-dir`），程序立刻結束、exit 0、無視窗、port 無監聽。

這是刻意的安全控制，理由很硬：CDP 一開，任何本機程序都能讀你的 session token、對話內容、MCP 憑證。Codex 沒擋所以 Dream Skin 能用，Claude 擋了。

繞過去唯一的辦法是改 `app.asar` 或重簽 binary，那會破壞 code signature、每次更新被覆蓋、而且把帳號憑證暴露給整台機器。**本專案不做這件事**，改走官方支援的 `SessionStart` hook，換來的是升級不會壞、憑證不外洩。

## 適用範圍

| 目標 | 支援 |
|---|---|
| 桌面 app 的 Code 分頁 | ✅ |
| 終端機的 `claude` CLI | ✅ |
| 桌面 app 的首頁（Welcome back 那一頁） | ❌ 那是 app 自己的畫面 |
| 桌面 app 的 Chat 分頁 | ❌ 沒有 hook 系統 |
| 視窗底圖／自訂 CSS | ❌ 見上一節 |

畫面出現的位置是**對話的最上面**，不是 app 首頁。

顏色靠 truecolor ANSI。若你的環境不吃跳脫碼，`CLAUDE_SKIN_COLOR=0` 會退回字元畫，`CLAUDE_SKIN_QUIET=1` 只印一行字。

## 動到哪些檔案

```
~/.claude/settings.json                     加 hooks.SessionStart
~/.claude/settings.json.pre-skin-<時間戳>    首次套用前的完整備份
~/.claude/output-styles/<skin>.md           只有 --with-persona 才會裝
~/.claude/claude-skin-state.json            記錄原狀，restore 用
```

`restore` 只移除本工具加的東西，不動你原本的設定，備份檔也會留著。

## 說明

本專案**不含任何藝人照片**。`photo.ansi` 由使用者自己的圖檔在本機產生，已列入 `.gitignore`。

這是粉絲向的個人化工具，與權志龍本人及其經紀公司無關，不代表任何人發言，也不是官方或本人背書的產品。放什麼照片是你自己的事，請自行確認你有使用該圖的權利。

## 授權

MIT
