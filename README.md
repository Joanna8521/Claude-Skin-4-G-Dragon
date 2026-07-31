# Claude Skin

**English** · [繁體中文](README.zh-TW.md)

Your photo and a line of encouragement at the top of every new Claude Code conversation.

```
list what's already done                ← whatever you actually typed

┌────────────┐
│            │
│ your photo │
│            │
└────────────┘
Before you start, a word

You got through today too. That counts for something.

Here's what's done so far: …          ← then it answers you
```

Queue up several lines and one is picked at random, or pin a specific line for today. Write `{project}` in a line and it's replaced with whatever project you're in.

---

## Requirements

- macOS (uses the built-in `sips` for image conversion)
- Claude Code (desktop app or CLI)
- Python 3.8+ (ships with macOS)

No `pip install`, no `brew install`. Zero dependencies.

## Install

```bash
git clone https://github.com/Joanna8521/Claude-Skin-4-G-Dragon.git
cd Claude-Skin-4-G-Dragon
./install.sh
```

That's the whole install. `install.sh` checks your environment, symlinks `claude-skin` into `~/.local/bin`, registers the SessionStart hook in `~/.claude/settings.json`, and prints your next steps.

**Keep the cloned folder.** The hook runs scripts from it, so deleting or moving the repo breaks the greeting. If you do move it, re-run `./install.sh` from the new location — it cleans up the old registration.

To install the command somewhere other than `~/.local/bin`:

```bash
CLAUDE_SKIN_BIN=/usr/local/bin ./install.sh
```

If `~/.local/bin` isn't on your `PATH`, the installer prints the exact line to add to `~/.zshrc`.

### Uninstall

```bash
claude-skin restore
```

Removes the hook, restores your previous `outputStyle`, and deletes every photo copy it placed in your projects. Your `~/.claude/settings.json` backup is kept. After that you can delete the cloned folder.

---

## Three steps to start

### 1. Add your photo

**This repo ships no photo.** Start with the crop tool:

```bash
claude-skin crop ~/Pictures/me.jpg
```

It writes a web page — open it in a browser. Your photo has a pink box on it: **drag to move, pull the pink dot to resize.** The exact command appears underneath and updates live. Hit copy, paste it into your terminal, and the photo is set.

Why cropping matters: the greeting shows a small square. A full-body shot shrinks the face to almost nothing. Cropping to the face makes a large difference.

#### Several photos, picked at random

```bash
claude-skin photo ~/Pictures/second.jpg --add
claude-skin photo ~/Pictures/third.jpg --add
```

`--add` **adds to the pool** instead of replacing it, and one is picked at random each session. Without `--add`, the pool is cleared and only the new photo remains.

```bash
claude-skin photos          # list the pool, numbered
claude-skin photos -d 2     # delete photo 2
```

`photos` also writes a contact sheet you can open in a browser, so you can see which number is which before deleting.

<details>
<summary>Skip the browser, use flags instead</summary>

```bash
claude-skin photo ~/Pictures/me.jpg
```

Uses the whole image. To specify the crop yourself:

```bash
claude-skin photo ~/Pictures/me.jpg -c 400x400+240+129
```

That's `width x height + leftX + topY`, in source-image pixels.

Accepts jpg, png, avif, heic, webp.
</details>

### 2. Add a few lines you'd want to read

```bash
claude-skin add "Keep pushing {project} today"
claude-skin add "Stuck? Get up and walk around, it'll come to you"
claude-skin add "It's past midnight, go to sleep" -t latenight
```

Lines added this way **stay forever**, and one is picked at random each time.

The default skin ships with lines already, so you can skip this step.

### 3. Open a new conversation and say anything

The greeting appears at the top of Claude's first reply, then it answers whatever you asked.

---

## Two kinds of lines

This is the part that's easy to confuse, so up front:

| | Command | Lifetime | When to use it |
|---|---|---|---|
| **Random pool** | `claude-skin add` | Permanent | Things you'd like to hear generally |
| **Today only** | `claude-skin say` | Expires at midnight | A specific goal you want in front of you today |

`say` **overrides** the pool while it's set, and expires automatically at midnight.

### The random pool

```bash
claude-skin add "some line"              # any time of day (default)
claude-skin add "some line" -t latenight # only after 23:00
claude-skin lines                        # list the pool, numbered
claude-skin lines -d 3                   # delete line 3
```

Time tags:

| Tag | Hours |
|---|---|
| `any` | always eligible (default) |
| `morning` | 05:00 – 11:00 |
| `afternoon` | 11:00 – 18:00 |
| `night` | 18:00 – 23:00 |
| `latenight` | 23:00 – 05:00 |

You can also edit `skins/<name>/greetings.txt` directly — format is `tag|text`, `#` starts a comment, saves take effect immediately.

### Today only

```bash
claude-skin say "Just get {project} pushed today"
claude-skin say            # show what's set for today
claude-skin say --clear    # drop it, back to the pool
```

**Change it whenever you want** — ten times a day is fine, each replaces the last, and it applies to your next new conversation.

Skipping it is fine too; you just get the pool. This is not a daily chore.

### The `{project}` placeholder

Works in both kinds of lines. It's replaced with the name of the directory you're working in:

```bash
claude-skin add "Keep pushing {project} today"
```

In `Python 2025` that reads "Keep pushing Python 2025 today"; in `Grow4ai` it reads Grow4ai. **Write it once, stays relevant everywhere.**

---

## Tuning it

### The small caption above the line

Lives in `skins/<name>/skin.json`:

```json
{
  "custom_label": "Before you start, a word",
  "random_label": "Today's nudge"
}
```

`custom_label` is used for lines set with `say`, `random_label` for pool lines. Set them differently if you want to tell the two apart.

### Making it appear without typing anything (off by default)

The greeting rides along on Claude's reply, so it shows up the moment you send your first message — whatever that message is.

If you want it to appear the instant you open a conversation, without typing at all, the hook can send an opener for you:

```json
{ "auto_greet": true, "auto_greet_text": "let's go" }
```

**This is off by default, and the reason is worth knowing.** The opener is injected as a user message, so when you do type something yourself, the transcript shows your message *plus* a second bubble you never wrote. It reads like you said the same thing twice. In practice that's more annoying than typing one word, which is why the default is off.

---

## Command reference

```bash
claude-skin list              # available skins
claude-skin apply <name>      # apply one
claude-skin current           # which one is active
claude-skin preview <name>    # see what gets sent to Claude
claude-skin restore           # undo everything, remove every copy

claude-skin add <text> [-t tag]   # add to the random pool (permanent)
claude-skin lines                 # list the pool, numbered
claude-skin lines -d <n>          # delete one
claude-skin say <text>            # today only (overrides the pool)
claude-skin say --clear           # drop today's line

claude-skin crop <image>          # visual crop picker
claude-skin photo <image> [-c]    # set the photo (replaces the pool)
claude-skin photo <image> --add   # add to the pool, picked at random
claude-skin photos                # list the pool, numbered
claude-skin photos -d <n>         # delete one
```

`apply` and `restore` need a new conversation or `/clear`. Everything else applies to your next new conversation.

---

## Making your own skin

```
skins/<name>/
├── skin.json        # name, labels, auto_greet settings
├── greetings.txt    # the random pool
├── photo.jpg        # your photo (gitignored)
├── today.txt        # today's line (gitignored)
└── persona.md       # optional personality
```

Copy a skin directory, rename it, make `name` in `skin.json` match the folder name, then `claude-skin apply <yours>`.

## Optional: change Claude's tone too

```bash
claude-skin apply <name> --with-persona
```

Installs `persona.md` as a Claude Code output style. **Off by default** — without the flag, `outputStyle` is never touched.

`persona.md` holds one hard rule: if tests fail, say they failed; if something isn't done, say so; if you're unsure, say you're unsure. Bad news can be delivered warmly, but never softened into inaccuracy.

An AI that says "almost there!" while the tests are all red is more dangerous than one with no personality at all. Keep that section if you write your own.

---

## Troubleshooting

Every entry here is something that actually happened while building this.

### `claude-skin: command not found`

`~/.local/bin` isn't on your `PATH`.

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

Then **restart your terminal**. Or skip `PATH` entirely and use the full path: `~/Claude-Skin-4-G-Dragon/bin/claude-skin list`

### No greeting at all in a new conversation

Check in this order:

```bash
claude-skin current            # is a skin applied?
claude-skin preview gd-oppa    # does the hook produce output?
```

If `current` says nothing is applied, run `claude-skin apply gd-oppa`.

If it is applied and you still see nothing, you're probably looking at an **already-open conversation**. The hook runs once at session start — you need a **new conversation** or `/clear`.

### It worked yesterday, nothing today

You moved or deleted the cloned folder. The hook executes scripts from it, so a broken path kills the greeting.

Re-run the installer from wherever it lives now:

```bash
cd /new/path/Claude-Skin-4-G-Dragon
./install.sh
```

It clears the old registration, so nothing is left behind.

### The photo shows up as a blue link instead of an image

The markdown image path was rejected. Desktop-app rule: **the image must resolve inside the working directory.** Absolute paths and `../` escapes both degrade to links.

The hook handles this automatically. If it still happens:

```bash
claude-skin photo ~/Pictures/me.jpg
```

That rebuilds the per-project copies. Note that if a project directory isn't writable, the hook silently drops the image and shows text only — deliberate, so one bad directory can't break the whole greeting.

### The photo is an unrecognizable blur

You used a full-body or group shot. The greeting shows a small square, so a face gets shrunk to a handful of pixels.

```bash
claude-skin crop ~/Pictures/me.jpg
```

Drag a box around the face and run the command it gives you. The difference is large.

### Two identical message bubbles

`auto_greet` is on and `auto_greet_text` collides with something you type often.

Set `"auto_greet": false` in `skins/<name>/skin.json` (that's the default), or pick a word you'd never type.

### The greeting takes several seconds

Claude used `show_widget` to build the card, which means base64-encoding the image and streaming it every session — thousands of tokens.

The hook explicitly forbids this. If it still happens, run `claude-skin preview <name>` and check the instructions contain the "don't use show_widget" line. If they don't, your copy is out of date — `git pull`.

### The photo got committed to my project

The hook appends `claude-skin.jpg` to `<project>/.claude/.gitignore`, but if you committed before that:

```bash
git rm --cached .claude/claude-skin.jpg
```

### Remove everything

```bash
claude-skin restore
```

Removes the hook, restores `outputStyle`, and deletes every per-project photo copy. Your settings backup is kept at `~/.claude/settings.json.pre-skin-<timestamp>`.

After that you can delete the cloned folder.

### See exactly what gets sent to Claude

```bash
claude-skin preview gd-oppa
```

Prints the full instruction the hook generates — image path, caption, and the line that will appear. Start here whenever the greeting looks wrong.

---

## Why it's built this way

Almost every design decision here was forced by a limitation of the Claude Code desktop app. None of it is preference. This section maps each constraint to the shape it forced, because if you're building something similar you will hit the same walls.

| Constraint | What I wanted to build | What it forced |
|---|---|---|
| Hook stdout never reaches the screen | The hook prints the greeting itself | Ask Claude to print it instead |
| `systemMessage` doesn't render either | Use the documented "shown to the user" field | Same — Claude's reply is the only channel |
| Images resolve only inside the working directory | One shared photo in the home directory | Copy the photo into every project |
| `initialUserMessage` leaves a visible bubble | Greeting with zero typing | Shipped off by default |
| CDP is blocked in the main process | Full-window background image, like Codex | Abandoned entirely |

Details below. All of it is from testing, not documentation.

### 1. Hook stdout is not shown to the user

The docs say SessionStart stdout "is shown to the user and injected into Claude's context."

**In the desktop app, only the second half is true.** stdout is recorded in the transcript as `type: "attachment"` — fed to the model, never painted on screen. However pretty your ASCII art is, only Claude "sees" it.

### 2. `systemMessage` isn't shown either

The docs describe `systemMessage` as a "warning message shown to the user." Tested in a fresh desktop-app conversation: it doesn't appear on screen.

**So the only channel that reliably renders for the user is Claude's own reply.** That's why this hook prints nothing and asks Claude to do the printing instead. It turned out better anyway — a reply can show a real image, not terminal color blocks.

### 3. Markdown images must live inside the working directory

Two rules, both found by testing:

1. `![](/absolute/path.jpg)` renders as a blue autolink, not an image. Same for `file://` URLs, and for absolute paths wrapped in `<>` to escape spaces.
2. A relative path works — but only if it resolves to somewhere **under** the working directory. Escaping upward with `../` fails the same way.

So a single shared copy in your home directory can't work. The hook copies the photo into `<project>/.claude/claude-skin.jpg` at session start and references it as `.claude/claude-skin.jpg`. Hidden directories render fine.

This means **the greeting works in every project**, not just this one — you don't have to set anything up per project. The tradeoff is a 21 KB file in each project you open a conversation in. The hook also appends `claude-skin.jpg` to `<project>/.claude/.gitignore` so it can't be committed by accident, records every directory it touched, and `claude-skin restore` deletes them all.

### 4. `initialUserMessage` is real, but you probably don't want it

SessionStart accepts `initialUserMessage`, which prepends a message as if the user had typed it. It works — Claude replies immediately, so the greeting appears with zero input from you.

The catch is that it's a real user message in the transcript. When you then type something of your own, you see your message and a second bubble you never wrote. It reads like a stutter. Shipped off by default.

### 5. Full-window backgrounds are blocked by design

[Codex Dream Skin](https://github.com/Fei-Away/Codex-Dream-Skin) attaches to the Codex desktop app over local CDP and injects CSS to replace the whole window with an image. That is not possible on Claude.

Claude.app (Electron 42.7.0) guards its launch arguments in the main process:

```js
A.some(g => {
  const I = g.replace(/^(?:--|-|\/)/, "").toLowerCase();
  return I.startsWith("remote-debugging-port") || I.startsWith("remote-debugging-pipe")
})
```

Launching with `--remote-debugging-port=9223` (isolated `--user-data-dir`) exits immediately: exit 0, no window, nothing listening on the port.

This is deliberate. An open CDP port lets any local process read your session token, conversation contents, and MCP credentials. Codex doesn't block it, which is what makes Dream Skin possible; Claude does.

The only way around it is patching `app.asar` or re-signing the binary — which breaks the code signature, gets overwritten on every update, and exposes your credentials to the whole machine. **This project doesn't do that.**

---

## Scope

| Target | Supported |
|---|---|
| Desktop app, Code tab | ✅ |
| Terminal `claude` CLI | ✅ text yes, images depend on your terminal |
| Desktop app home screen ("Welcome back") | ❌ that's the app's own UI |
| Desktop app, Chat tab | ❌ no hook system |
| Window background / custom CSS | ❌ see above |

The greeting appears at the **top of Claude's reply**, not on the app's home screen.

## Files touched

```
~/.claude/settings.json                     adds hooks.SessionStart
~/.claude/settings.json.pre-skin-<stamp>    full backup before first apply
~/.claude/output-styles/<skin>.md           only with --with-persona
~/.claude/claude-skin-state.json            records prior state for restore
~/.claude/claude-skin/<skin>/*.jpg          photo pool, one picked at random
~/.claude/claude-skin/projects.txt          projects that received a copy
<project>/.claude/claude-skin.jpg           per-project copy (auto-gitignored)
```

`claude-skin restore` removes only what this tool added. Your own settings are left alone and the backup is kept.

## Note

This repo **contains no celebrity photos**. `photo.jpg` is whatever you put there, and it's gitignored.

This is a fan-made personalization tool. It is not affiliated with, endorsed by, or speaking for G-Dragon or his agency. Whatever image you use is your own responsibility — make sure you have the right to use it.

## License

The code is MIT. See [LICENSE](LICENSE).

**MIT covers this tool only — not the images you feed it.** Photos you add with `claude-skin photo` stay on your machine and are never committed (they're gitignored). Whatever rights apply to those images are between you and whoever owns them; this project doesn't grant you any.

If you fork this repo and want to ship a demo image in it, make sure you actually hold the rights to distribute that image. A photo you found online usually doesn't qualify, even if it's widely reposted, and even if it looks AI-generated.
