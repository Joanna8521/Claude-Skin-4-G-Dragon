# Claude Skin

[English](README.md) · **繁體中文**

開新對話時，你的照片和一句打氣話會出現在 Claude 回覆的最上面。

```
列出已經完成的工作項目                    ← 你自己打的，什麼都行

┌────────────┐
│            │
│   你的照片   │
│            │
└────────────┘
開工前，歐巴有些話想對妳說

今天只要把 Python 2025 推上 GitHub 就贏了！

已完成的項目如下：…                      ← 接著直接回答你
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

裝這樣就好。`install.sh` 會檢查環境、把 `claude-skin` 連結到 `~/.local/bin`、在 `~/.claude/settings.json` 註冊 SessionStart hook，最後印出接下來要做什麼。

**clone 下來的資料夾要留著。** hook 會執行裡面的程式，資料夾刪掉或搬走問候就會失效。真的要搬的話，在新位置重跑一次 `./install.sh`，它會把舊的註冊清掉。

想裝到別的地方：

```bash
CLAUDE_SKIN_BIN=/usr/local/bin ./install.sh
```

`~/.local/bin` 不在 `PATH` 裡的話，安裝程式會印出該加進 `~/.zshrc` 的那一行。

### 移除

```bash
claude-skin restore
```

會移除 hook、還原你原本的 `outputStyle`、刪掉散在各專案裡的照片副本。`~/.claude/settings.json` 的備份會留著。做完就可以把 clone 的資料夾刪了。

---

## 三步開始用

### 第一步：放你的照片

**repo 沒有附照片**，用你自己的。先開裁切工具：

```bash
claude-skin crop ~/Pictures/我的照片.jpg
```

會產生一個網頁，用瀏覽器打開。圖上有一個粉紅色方框：**拖它移動、拉右下角的粉紅點改大小**。下面會即時顯示對應的指令，按「複製指令」貼回終端機執行，照片就換好了。

為什麼一定要裁：開場卡上的圖是一個小方框，全身照塞進去臉會小到看不清楚。裁到臉差別非常大。

#### 多放幾張，讓它隨機跳

```bash
claude-skin photo ~/Pictures/第二張.jpg --add
claude-skin photo ~/Pictures/第三張.jpg --add
```

加了 `--add` 就是**加進池子**而不是取代，每次開場隨機挑一張。不加 `--add` 會清空池子只留新的那張。

```bash
claude-skin photos          # 看池子裡有幾張，附編號
claude-skin photos -d 2     # 刪掉第 2 張
```

`photos` 除了列清單，還會產一張網頁對照表，用瀏覽器打開就看得到哪張是幾號，才不會刪錯。

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

### 第三步：開一個新對話，隨便說一句話

問候會出現在 Claude 回覆的最上面，接著它直接回答你問的事。

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

### 要不要完全不用打字就出現（預設關閉）

問候是搭 Claude 的回覆出現的，所以你送出第一句話（不管是什麼）它就會跟著出來。

如果你想連一個字都不打，一開對話就看到，hook 可以幫你代送一句開場：

```json
{ "auto_greet": true, "auto_greet_text": "開工" }
```

**預設關掉，理由值得知道。** 代送的那句是真的以「使用者訊息」的身分進到對話裡，所以當你自己打字的時候，畫面上會是你打的那句，**再加一個你沒打過的泡泡**，看起來像同一句話講了兩次。實際用起來這個比多打一個字還煩，所以預設不開。

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
claude-skin photo <圖> [-c 範圍]    # 換照片（取代池子）
claude-skin photo <圖> --add       # 加進照片池，開場隨機挑
claude-skin photos                 # 看照片池，附編號
claude-skin photos -d <編號>       # 刪掉一張
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

## 疑難排解

以下每一條都是實際踩過的，不是想像出來的。

### `claude-skin: command not found`

`~/.local/bin` 不在你的 `PATH` 裡。

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

然後**重開終端機**。不想改 PATH 的話，直接用完整路徑跑也可以：`~/Claude-Skin-4-G-Dragon/bin/claude-skin list`

### 開新對話後完全沒有問候

依序檢查：

```bash
claude-skin current     # 有沒有套用
claude-skin preview gd-oppa   # hook 產得出東西嗎
```

`current` 說沒套用 → 跑 `claude-skin apply gd-oppa`。

有套用但還是沒出現 → 你可能是在**已經開著的對話**裡看。hook 只在 session 啟動時跑一次，要**開新對話**或 `/clear` 才會生效。

### 昨天還好好的，今天突然不出現了

你把 clone 下來的資料夾搬走或刪掉了。hook 會執行資料夾裡的程式，路徑一斷就整個失效。

搬到新位置後重跑一次安裝：

```bash
cd /新位置/Claude-Skin-4-G-Dragon
./install.sh
```

會自動清掉舊的註冊，不會留殘留。

### 照片沒出來，變成一條藍色連結

代表 markdown 圖片路徑不被接受。這是桌面 app 的規則：**圖片必須在工作目錄底下**，絕對路徑和 `../` 跳出去都會變成連結。

正常情況 hook 會自動處理。真的遇到的話：

```bash
claude-skin photo ~/Pictures/你的照片.jpg
```

重跑一次會重建各專案的副本。如果那個專案目錄**沒有寫入權限**，hook 會安靜地放棄圖片只出文字，這是刻意的，不會讓整個問候掛掉。

### 照片糊成一片馬賽克

你放的是全身照或大合照。開場卡的圖是小方框，臉會被縮到剩幾個像素。

```bash
claude-skin crop ~/Pictures/你的照片.jpg
```

拖出臉的範圍，複製它給的指令執行。差別非常大。

### 畫面上出現兩個一樣的泡泡

`auto_greet` 開著，而且 `auto_greet_text` 跟你自己打的字撞了。

`skins/<name>/skin.json` 設 `"auto_greet": false`（這是預設值），或換一個你不會打的詞。

### 開場要等好幾秒

Claude 拿 `show_widget` 去畫那張卡了，每次都要把圖轉成 base64 再串出來，會燒掉幾千個 token。

hook 的指示裡已經明確禁止這件事。還是發生的話，跑 `claude-skin preview <name>` 確認指示裡有「不要用 show_widget」那一行；沒有的話你的版本太舊，`git pull` 更新。

### 照片被 commit 進我的專案了

hook 會自動在 `<專案>/.claude/.gitignore` 補一條 `claude-skin.jpg`，但如果你在那之前就 commit 了：

```bash
git rm --cached .claude/claude-skin.jpg
```

### 想把所有東西清乾淨

```bash
claude-skin restore
```

會移除 hook、還原 `outputStyle`、刪掉散在每個專案裡的照片副本。`~/.claude/settings.json` 的備份不會刪，位置在 `~/.claude/settings.json.pre-skin-<時間戳>`。

清完就可以把 clone 的資料夾刪了。

### 想確認它到底送了什麼給 Claude

```bash
claude-skin preview gd-oppa
```

會印出 hook 產生的完整指示，包含圖片路徑、小標題、今天會出現的句子。開場不對勁時先看這個。

---

## 為什麼是這個設計

這裡幾乎每一個設計決定，都是被 Claude Code 桌面 app 的某個限制逼出來的，不是偏好。這一節把每個限制對到它逼出來的形狀，因為你如果要做類似的東西，會撞到一模一樣的牆。

| 限制 | 原本想做的 | 被逼成 |
|---|---|---|
| hook 的 stdout 不會顯示在畫面上 | hook 自己印出開場畫面 | 改成請 Claude 代印 |
| `systemMessage` 也不顯示 | 用官方標示「會顯示給使用者」的欄位 | 同上，只剩 Claude 的回覆這條路 |
| 圖片只認工作目錄底下的相對路徑 | 家目錄放一份大家共用 | 每個專案複製一份照片 |
| `initialUserMessage` 會留下泡泡 | 完全不用打字就出現問候 | 預設關閉 |
| CDP 在 main process 被擋 | 像 Codex 那樣做滿版底圖 | 整個放棄 |

以下是細節，全部來自實測，不是文件。

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

### 4. `initialUserMessage` 真的能用，但你大概不會想要

SessionStart 接受 `initialUserMessage`，會以「使用者打的」身分預先塞一句話進對話。它確實有效，Claude 會立刻回應，所以問候可以在你完全沒輸入的情況下出現。

問題是那句話在 transcript 裡是**真的使用者訊息**。當你自己打字時，畫面上會出現你打的那句，再加一個你沒寫過的泡泡，讀起來像同一句講了兩次。所以預設關閉。

### 5. 滿版底圖這條路被官方擋死

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

問候出現的位置是 **Claude 回覆的最上面**，不是 app 首頁。

## 動到哪些檔案

```
~/.claude/settings.json                     加 hooks.SessionStart
~/.claude/settings.json.pre-skin-<時間戳>    首次套用前的完整備份
~/.claude/output-styles/<skin>.md           只有 --with-persona 才會裝
~/.claude/claude-skin-state.json            記錄原狀，restore 用
~/.claude/claude-skin/<skin>/*.jpg          照片池，開場隨機挑一張
~/.claude/claude-skin/projects.txt          放過副本的專案清單
<專案>/.claude/claude-skin.jpg              各專案的照片副本（自動 gitignore）
```

`claude-skin restore` 只移除本工具加的東西，不動你原本的設定，備份檔也會留著。

## 說明

本專案**不含任何藝人照片**。`photo.jpg` 是使用者自己放的，已列入 `.gitignore`。

這是粉絲向的個人化工具，與權志龍本人及其經紀公司無關，不代表任何人發言，也不是官方或本人背書的產品。放什麼照片是你自己的事，請自行確認你有使用該圖的權利。

## 授權

MIT
