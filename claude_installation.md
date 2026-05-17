# Claude Code installation

Official project: <https://docs.claude.com/en/docs/claude-code>

[Claude Code](https://www.anthropic.com/claude-code) is Anthropic's terminal
coding agent. In this setup it runs **inside WSL Ubuntu**, in the same shell the
rest of this repo configures, typically through [WezTerm](wezterm_windows_setup.md)
and [Zellij](zellij_installation.md).

## Install or confirm

Check whether it is already installed:

```bash
claude --version
```

If the command is missing, install with the official installer (no Node.js
required — it manages its own runtime):

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Alternatively, if you prefer npm and already have Node via
[fnm](fnm_installation.md):

```bash
npm install -g @anthropic-ai/claude-code
```

The installer puts the binary under `~/.local/bin`, which this setup already
keeps on `PATH`. Re-running either command upgrades in place, so this step is
idempotent. Update later with:

```bash
claude update
```

## First run

Launch it from any project directory:

```bash
claude
```

On first run it walks through authentication in the browser. Sessions, settings
and keybindings live under `~/.claude/`.

## Verify

```bash
claude --version
claude doctor
```

`claude doctor` reports installation health and also validates
`~/.claude/keybindings.json` (see the next section).

## Image paste in WSL (mandatory)

Pasting an image from the Windows clipboard into Claude Code under WSL requires
a **two-part** setup. Both halves are mandatory — with only one, `Ctrl+Shift+V`
arrives as the same byte as `Ctrl+V` and image paste silently does nothing.

**Why:** in legacy terminal encoding `Ctrl+V` and `Ctrl+Shift+V` are the *same*
byte (`0x16`) — Shift on a control key is unrepresentable. Claude Code requests
the **Kitty keyboard protocol** so modifiers become distinguishable; WezTerm
must be told to honor it (it does not by default).

### Part 1 — WezTerm (Windows side)

In `C:\Users\<you>\.wezterm.lua` (editable from WSL at
`/mnt/c/Users/<you>/.wezterm.lua`):

```lua
config.enable_kitty_keyboard = true

config.keys = {
	-- Paste text with Ctrl+V (WezTerm default is Ctrl+Shift+V).
	{ key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
	-- Let Ctrl+Shift+V pass through to Claude instead of WezTerm pasting text.
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
}
```

Full file and rationale: [WezTerm on Windows](wezterm_windows_setup.md). WezTerm
hot-reloads on save.

### Part 2 — Claude Code (WSL side)

Create or merge `~/.claude/keybindings.json` so image paste moves from `Ctrl+V`
(now used by WezTerm for text paste) to `Ctrl+Shift+V`:

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "$docs": "https://code.claude.com/docs/en/keybindings",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+v": null,
        "ctrl+shift+v": "chat:imagePaste"
      }
    }
  ]
}
```

If the file already exists, merge these entries into the existing `Chat`
context rather than overwriting the file.

### Net result

- `Ctrl+V` → pastes **text** (handled by WezTerm)
- `Ctrl+Shift+V` → pastes an **image** into Claude Code

### Apply and verify

1. Save both files.
2. **Restart Claude Code** in a fresh WezTerm tab so it re-negotiates the
   keyboard protocol on the new session.
3. Copy an image to the clipboard and press `Ctrl+Shift+V` in Claude.

To confirm the terminal now sends distinct sequences independent of Claude,
run this in a new WezTerm tab and press `Ctrl+V` then `Ctrl+Shift+V`
(`Ctrl+C` quits):

```bash
python3 - <<'EOF'
import sys, tty, termios
fd = sys.stdin.fileno(); old = termios.tcgetattr(fd)
sys.stdout.write("\x1b[>1u"); sys.stdout.flush()
print("Press Ctrl+V, then Ctrl+Shift+V. Ctrl+C quits.\r")
try:
    tty.setraw(fd)
    while True:
        b = sys.stdin.buffer.read(1)
        if b == b"\x03": break
        sys.stdout.write(repr(b) + "\r\n"); sys.stdout.flush()
finally:
    termios.tcsetattr(fd, termios.TCSADRAIN, old)
    sys.stdout.write("\x1b[<u"); sys.stdout.flush()
EOF
```

`Ctrl+V` should print a single `b'\x16'`; `Ctrl+Shift+V` should print a
multi-byte escape sequence ending in `b'u'` (`ESC [ 118 ; 6 u`). Different
output confirms the setup. Identical `b'\x16'` for both means Part 1 is not
in effect.

## Notes

- Keybindings reference: <https://code.claude.com/docs/en/keybindings>. The
  action for image paste is `chat:imagePaste`.
- Any WezTerm keyboard-protocol change requires restarting Claude Code (not
  just reloading WezTerm) so the protocol is re-negotiated.
