# Claude Skin

[English](README.md) · **繁體中文**

開新對話時，你的照片和一句打氣話會出現在最上面。你什麼都不用打。

```
開工                                    ← 工具自動送的，你不用打

┌────────────┐
│            │
│   你的照片   │
│            │
└────────────┘
開工前，歐巴有些話想對妳說

今天只要把 Python 2025 推上 GitHub 就贏了！
```

句子可以排好幾句讓它隨機跳，也可以指定今天要出現哪一句。句子裡寫 `{project}` 會自動換成你當下所在的專案名稱。

---

## 需要什麼

- macOS（圖片轉檔用系統內建的 `sips`）
- Claude Code（桌面 app 或終端機 CLI 都可以）
- Python 3.8 以上（macOS 內建）

不用 `pip install`，也不用 `brew install`。零依賴。

## 安裝

```bash
git clone https://github.com/Joanna8521/Claude-Skin-4-G-Dragon.git
cd Claude-Skin-4-G-Dragon
./install.sh
```

會把 `claude-skin` 指令連結到 `~/.local/bin`，並套用預設 skin。如果那個目錄不在你的 `PATH` 裡，安裝程式會告訴你要在 `~/.zshrc` 加哪一行。

---

## 三步開始用

### 第一步：放你的照片

**repo 沒有附照片**，用你自己的。先開裁切工具：

```bash
claude-skin crop ~/Pictures/我的照片.jpg
```

會產生一個網頁，用瀏覽器打開。圖上有一個粉紅色方框：**拖它移動、拉右下角的粉紅點改大小**。下面會即時顯示對應的指令，按「複製指令」貼回終端機執行，照片就換好了。

為什麼一定要裁：開場卡上的圖是一個小方框，全身照塞進去臉會小到看不清楚。裁到臉差別非常大。

<details>
<summary>不想開網頁，想直接下指令</summary>

```bash
claude-skin photo ~/Pictures/我的照片.jpg
```

整張圖直接用。想自己指定裁切範圍：

```bash
claude-skin photo ~/Pictures/我的照片.jpg -c 400x400+240+129
```

格式是 `寬x高+左上角X+左上角Y`，單位是原圖的像素。

jpg、png、avif、heic、webp 都吃。
</details>

### 第二步：放幾句想聽的話

```bash
claude-skin add "今天也要把 {project} 好好推進一點喔！"
claude-skin add "卡關了就先站起來走一走，腦袋會自己想通的"
claude-skin add "凌晨了啦！先去睡好不好？" -t latenight
```

加進去的句子會**一直留著**，每次開場隨機抽一句。

內建已經有 14 句，所以這步跳過也可以。

### 第三步：開一個新對話

就這樣。照片和句子會出現在對話最上面。

---

## 兩種句子

這是這個工具最容易搞混的地方，先講清楚：

| | 指令 | 效期 | 用在什麼時候 |
|---|---|---|---|
| **隨機池** | `claude-skin add` | 永久 | 平常想聽的話，排幾句讓它跳 |
| **今天限定** | `claude-skin say` | 只有當天 | 今天有特定目標，想看到那一句 |

`say` 設了就會**蓋掉**隨機池，隔天午夜自動失效，換回隨機。

### 隨機池

```bash
claude-skin add "句子"              # 加一句，預設任何時段都可能抽到
claude-skin add "句子" -t latenight # 只在凌晨出現
claude-skin lines                   # 看池子裡有哪些，附編號
claude-skin lines -d 3              # 刪掉第 3 句
```

時段標籤：

| 標籤 | 時間 |
|---|---|
| `any` | 任何時候（預設） |
| `morning` | 05:00 – 11:00 |
| `afternoon` | 11:00 – 18:00 |
| `night` | 18:00 – 23:00 |
| `latenight` | 23:00 – 05:00 |

也可以直接編 `skins/<name>/greetings.txt`，格式 `標籤|句子`，`#` 開頭是註解，存檔立刻生效。

### 今天限定

```bash
claude-skin say "今天只要把 {project} 推上 GitHub 就贏了"
claude-skin say            # 看今天設了什麼
claude-skin say --clear    # 清掉，馬上改回隨機
```

**想改就改，隨時。** 一天改十次也可以，後面蓋掉前面，下一個新對話生效。

不設也沒關係，不設就用隨機池。這不是每天的功課。

### `{project}` 佔位符

兩種句子都能用。會換成你當下所在的專案資料夾名稱：

```bash
claude-skin add "今天也要把 {project} 好好推進一點喔！"
```

在 `Python 2025` 開對話就顯示「今天也要把 Python 2025 好好推進一點喔！」，在 `Grow4ai` 就顯示 Grow4ai。**一句設定，每個專案都貼題。**

---

## 調整外觀與行為

### 照片旁邊那行小字

寫在 `skins/<name>/skin.json`：

```json
{
  "custom_label": "開工前，歐巴有些話想對妳說",
  "random_label": "開工前，歐巴有些話想對妳說"
}
```

`custom_label` 用在 `say` 設的句子，`random_label` 用在隨機抽到的。想區分兩者就填不一樣的。

### 要不要自動幫你開口

問候是 Claude「回覆」出來的，所以正常情況要你先講一句話它才會回。

預設會用 `initialUserMessage` 幫你代打一句開場，所以**你什麼都不用打，一開新對話就出現**。

代價是畫面上會有一個你沒打過的訊息泡泡，這無法避免，因為 Claude 沒有使用者訊息就不會開口。

```json
{ "auto_greet_text": "開工" }
```

**不要設成你自己常打的字**（例如「嗨」），否則你打一次、工具送一次，畫面上會出現兩個一樣的泡泡，看起來像卡住。

完全不要自動開口：

```json
{ "auto_greet": false }
```

改成你先講話，問候才跟著出現。

---

## 指令總表

```bash
claude-skin list              # 列出所有 skin
claude-skin apply <name>      # 套用
claude-skin current           # 看目前套哪個
claude-skin preview <name>    # 看會送給 Claude 的開場指示
claude-skin restore           # 還原成套用前的樣子，清掉所有副本

claude-skin add <文字> [-t 時段]   # 加一句進隨機池（永久）
claude-skin lines                  # 看池子，附編號
claude-skin lines -d <編號>        # 刪掉一句
claude-skin say <文字>             # 今天限定（會蓋掉隨機池）
claude-skin say --clear            # 清掉今天限定

claude-skin crop <圖>              # 視覺化裁切工具
claude-skin photo <圖> [-c 範圍]    # 換照片
```

`apply` 和 `restore` 要開新對話或 `/clear` 才生效。其他都是即時的，下一個新對話就看得到。

---

## 自己做一個 skin

```
skins/<name>/
├── skin.json        # 名稱、小標題、auto_greet 設定
├── greetings.txt    # 隨機池
├── photo.jpg        # 你的照片（gitignore）
├── today.txt        # 今天限定的句子（gitignore）
└── persona.md       # 人格（可選）
```

複製一份改名就是新 skin，`skin.json` 的 `name` 要和資料夾同名，然後 `claude-skin apply <你的名字>`。

## 可選：連 Claude 的語氣一起換

```bash
claude-skin apply <name> --with-persona
```

會把 `persona.md` 裝成 Claude Code 的 output style。**預設不加**，不加就完全不碰 `outputStyle`。

`persona.md` 裡寫死一條線：測試掛了就說掛了、沒做完就說沒做完、不確定就說不確定。壞消息可以用溫柔的語氣講，但不准為了哄人而修飾內容。

一個會說「差不多好了呦～」但其實測試全紅的 AI，比沒有人格的 AI 危險得多。要自己寫人格檔請保留這段。

---

## 桌面 app 的發現

做這個東西時實測出幾件文件沒寫、或跟文件不一致的事。留在這裡給後來的人省時間。

### 1. hook 的 stdout 不會顯示給使用者

官方文件說 SessionStart 的 stdout「is shown to the user and injected into Claude's context」。

**在桌面 app，只有後半句成立。** stdout 在 transcript 裡被記成 `type: "attachment"`，只餵給模型，不畫在螢幕上。所以 hook 印再漂亮的 ASCII art，使用者也看不到，只有 Claude「看得到」。

### 2. `systemMessage` 也不顯示

文件說 `systemMessage` 是「warning message shown to the user」。在桌面 app 的新對話實測，同樣沒有出現在畫面上。

**結論：唯一確定會渲染給使用者看的，是 Claude 自己的回覆。** 所以這支 hook 不印畫面，改用 `additionalContext` 請 Claude 代印。這也剛好比較好看，因為 Claude 的回覆能顯示真正的圖片，不是終端機色塊。

### 3. markdown 圖片必須放在工作目錄底下

兩條規則，都是實測出來的：

1. `![](/絕對/路徑.jpg)` 會渲染成一條藍色連結，不是圖片。`file://` 一樣，用 `<>` 包起來跳脫空白也一樣。
2. 相對路徑可以，但**必須落在工作目錄底下**。用 `../` 跳出去一樣不渲染。

所以沒辦法在家目錄放一份大家共用。hook 會在 session 開始時把照片複製到 `<專案>/.claude/claude-skin.jpg`，然後用 `.claude/claude-skin.jpg` 引用。隱藏目錄可以正常渲染。

這表示**每個專案都會出現**，不是只有這個專案，而且你不用為每個專案設定什麼。代價是你開過對話的每個專案裡會多一個 21 KB 的檔案。hook 會順便在 `<專案>/.claude/.gitignore` 補一條 `claude-skin.jpg` 免得被誤 commit，也會記錄放過哪些目錄，`claude-skin restore` 一次全部清掉。

### 4. 滿版底圖這條路被官方擋死

[Codex Dream Skin](https://github.com/Fei-Away/Codex-Dream-Skin) 用本機 CDP 連進 Codex 桌面 app 注入 CSS，把整個視窗換成一張圖。這在 Claude 上做不到。

Claude.app（Electron 42.7.0）的 main process 有一段啟動參數守衛：

```js
A.some(g => {
  const I = g.replace(/^(?:--|-|\/)/, "").toLowerCase();
  return I.startsWith("remote-debugging-port") || I.startsWith("remote-debugging-pipe")
})
```

實測用 `--remote-debugging-port=9223` 啟動（獨立 `--user-data-dir`），程序立刻結束、exit 0、無視窗、port 無監聽。

這是刻意的安全控制：CDP 一開，任何本機程序都能讀你的 session token、對話內容、MCP 憑證。Codex 沒擋所以 Dream Skin 能用，Claude 擋了。

繞過去只能改 `app.asar` 或重簽 binary，會破壞 code signature、每次更新被覆蓋、還把帳號憑證暴露給整台機器。**本專案不做這件事。**

---

## 適用範圍

| 目標 | 支援 |
|---|---|
| 桌面 app 的 Code 分頁 | ✅ |
| 終端機的 `claude` CLI | ✅ 文字會出現，圖片看終端機支不支援 |
| 桌面 app 的首頁（Welcome back 那頁） | ❌ 那是 app 自己的畫面 |
| 桌面 app 的 Chat 分頁 | ❌ 沒有 hook 系統 |
| 視窗底圖／自訂 CSS | ❌ 見上一節 |

問候出現的位置是**對話的最上面**，不是 app 首頁。

## 動到哪些檔案

```
~/.claude/settings.json                     加 hooks.SessionStart
~/.claude/settings.json.pre-skin-<時間戳>    首次套用前的完整備份
~/.claude/output-styles/<skin>.md           只有 --with-persona 才會裝
~/.claude/claude-skin-state.json            記錄原狀，restore 用
~/.claude/claude-skin/<skin>.jpg            照片主檔
~/.claude/claude-skin/projects.txt          放過副本的專案清單
<專案>/.claude/claude-skin.jpg              各專案的照片副本（自動 gitignore）
```

`claude-skin restore` 只移除本工具加的東西，不動你原本的設定，備份檔也會留著。

## 說明

本專案**不含任何藝人照片**。`photo.jpg` 是使用者自己放的，已列入 `.gitignore`。

這是粉絲向的個人化工具，與權志龍本人及其經紀公司無關，不代表任何人發言，也不是官方或本人背書的產品。放什麼照片是你自己的事，請自行確認你有使用該圖的權利。

## 授權

MIT
