# Claude Skin

**English** · [繁體中文](README.zh-TW.md)

Your own photo and a personal message, at the top of every new Claude Code conversation.

You don't have to say hello first. Open a new conversation and it's there.

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

This symlinks `claude-skin` into `~/.local/bin` and applies the default skin. If that directory isn't on your `PATH`, the installer tells you what to add to `~/.zshrc`.

## Getting started

### 1. Add your photo

**This repo ships no photo.** Use your own:

```bash
claude-skin photo ~/Pictures/me.jpg
```

Accepts jpg, png, avif, heic, webp.

### 2. Crop it to the part that matters

The greeting card shows a small square. A full-body shot shrinks the face to almost nothing, so crop it:

```bash
claude-skin crop ~/Pictures/me.jpg
```

This opens a web page with your photo and a draggable box. Drag to move, pull the pink dot to resize. The page prints the exact command underneath — copy it, paste it back into your terminal, done.

If you'd rather type coordinates yourself:

```bash
claude-skin photo ~/Pictures/me.jpg -c 400x400+240+129
```

That's `width x height + leftX + topY`, in source-image pixels.

### 3. Set today's message

```bash
claude-skin say "Just ship it today"
```

### 4. Open a new conversation

That's it. The photo and message appear at the top.

## Daily use

Two commands cover everything:

```bash
claude-skin say "whatever you need to hear today"
claude-skin photo <image>
```

**Change the message whenever you want** — ten times a day is fine, each one replaces the last. It takes effect in your next new conversation.

The message is date-stamped and **expires at midnight**. The next day it falls back to a random line from `greetings.txt`. So it's not a daily chore: set one when you want one, skip it and you get the default.

```bash
claude-skin say            # show today's message
claude-skin say --clear    # drop it, back to random
```

### Random lines

With nothing set, a line is picked at random from the pool matching the current time of day:

| Tag | Hours |
|---|---|
| `morning` | 05:00 – 11:00 |
| `afternoon` | 11:00 – 18:00 |
| `night` | 18:00 – 23:00 |
| `latenight` | 23:00 – 05:00 |
| `any` | always eligible |

Edit `skins/<name>/greetings.txt` to change them. Format is `tag|text`, `#` starts a comment. Saves take effect immediately — no re-apply needed.

Use this for lines you want **permanently**, as opposed to `say` which is just for today.

### The small label

The caption above the message lives in `skins/<name>/skin.json`:

```json
{
  "custom_label": "Today's note to yourself",
  "random_label": "Today's nudge"
}
```

`custom_label` is used for messages you set with `say`; `random_label` for the random ones.

## Auto-greeting

The greeting is rendered by Claude's reply, so normally you'd have to send a message before it appears.

By default the hook uses `initialUserMessage` to send a short "hi" for you, so the greeting shows up the moment you open a conversation. The cost: a message bubble you didn't type, and one model turn per session.

Turn it off in `skin.json`:

```json
{ "auto_greet": false }
```

Or change what it says:

```json
{ "auto_greet_text": "morning" }
```

## Commands

```bash
claude-skin list              # available skins
claude-skin apply <name>      # apply one
claude-skin preview <name>    # see what gets sent to Claude
claude-skin current           # which one is active
claude-skin restore           # undo everything

claude-skin say <text>        # today's message
claude-skin crop <image>      # visual crop picker
claude-skin photo <image>     # set the photo
```

`apply` and `restore` need a new conversation or `/clear`. `say`, `photo`, and edits to `greetings.txt` are immediate.

## Making your own skin

```
skins/<name>/
├── skin.json        # name, labels, auto_greet settings
├── greetings.txt    # random line pool
├── photo.jpg        # your photo (gitignored)
├── today.txt        # today's message (gitignored)
└── persona.md       # optional personality
```

Copy a skin directory, rename it, and make `name` in `skin.json` match the folder name.

## Optional: change Claude's tone too

```bash
claude-skin apply <name> --with-persona
```

Installs `persona.md` as a Claude Code output style. **Off by default** — without the flag, `outputStyle` is never touched.

`persona.md` holds one hard rule: if tests fail, say they failed; if something isn't done, say so; if you're unsure, say you're unsure. Bad news can be delivered warmly, but never softened into inaccuracy.

An AI that says "almost there!" while the tests are all red is more dangerous than one with no personality at all. Keep that section if you write your own.

## Three things about the desktop app

Findings from building this that the docs don't mention, or contradict. Saved here so the next person doesn't lose the same hours.

### 1. Hook stdout is not shown to the user

The docs say SessionStart stdout "is shown to the user and injected into Claude's context."

**In the desktop app, only the second half is true.** stdout is recorded in the transcript as `type: "attachment"` — fed to the model, never painted on screen. However pretty your ASCII art is, only Claude "sees" it.

### 2. `systemMessage` isn't shown either

The docs describe `systemMessage` as a "warning message shown to the user." Tested in a fresh desktop-app conversation: it doesn't appear on screen.

**So the only channel that reliably renders for the user is Claude's own reply.** That's why this hook prints nothing and asks Claude to do the printing instead. It turned out better anyway — a reply can show a real image, not terminal color blocks.

### 3. Full-window backgrounds are blocked by design

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

## Scope

| Target | Supported |
|---|---|
| Desktop app, Code tab | ✅ |
| Terminal `claude` CLI | ✅ text yes, images depend on your terminal |
| Desktop app home screen ("Welcome back") | ❌ that's the app's own UI |
| Desktop app, Chat tab | ❌ no hook system |
| Window background / custom CSS | ❌ see above |

The greeting appears at the **top of the conversation**, not on the app's home screen.

## Files touched

```
~/.claude/settings.json                     adds hooks.SessionStart
~/.claude/settings.json.pre-skin-<stamp>    full backup before first apply
~/.claude/output-styles/<skin>.md           only with --with-persona
~/.claude/claude-skin-state.json            records prior state for restore
```

`restore` removes only what this tool added. Your own settings are left alone and the backup is kept.

## Note

This repo **contains no celebrity photos**. `photo.jpg` is whatever you put there, and it's gitignored.

This is a fan-made personalization tool. It is not affiliated with, endorsed by, or speaking for G-Dragon or his agency. Whatever image you use is your own responsibility — make sure you have the right to use it.

## License

MIT
