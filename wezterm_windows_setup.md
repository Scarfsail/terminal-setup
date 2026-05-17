# WezTerm on Windows

Official project: <https://wezfurlong.org/wezterm/>

WezTerm is a GPU-accelerated terminal emulator. In this setup it runs as a
**Windows application** and opens directly into the **WSL Ubuntu** environment
that the rest of this repo configures. Multiplexing (tabs/panes) is intentionally
left to [Zellij](zellij_installation.md), so WezTerm itself stays minimal.

## Install or confirm

Install WezTerm on **Windows** (not inside WSL):

```powershell
winget install wez.wezterm
```

Alternatively download the installer from <https://wezfurlong.org/wezterm/install/windows.html>.

## Config file location

WezTerm reads its config from the **Windows** user profile, not from WSL:

- Windows path: `C:\Users\<you>\.wezterm.lua`
- Same file from inside WSL: `/mnt/c/Users/<you>/.wezterm.lua`

This means the config can be created and edited from a WSL session by writing to
the `/mnt/c/...` path. WezTerm **hot-reloads** the file on save — no restart needed.

## Configuration

Create `C:\Users\<you>\.wezterm.lua` with the following. It boots into Ubuntu/zsh,
stays minimal (no tab bar, since Zellij owns tabs/panes), opens maximized, and
uses a pure black background.

```lua
-- ~/.wezterm.lua  (Windows: C:\Users\<you>\.wezterm.lua)
-- WezTerm hot-reloads this file on save -- no restart needed.
-- Docs: https://wezfurlong.org/wezterm/config/files.html

local wezterm = require("wezterm")
local config = wezterm.config_builder() -- gives clearer error messages

--------------------------------------------------------------------------------
-- Default to WSL
--------------------------------------------------------------------------------
-- Open every window straight into Ubuntu (zsh), not Windows cmd/PowerShell.
config.default_domain = "WSL:Ubuntu"

--------------------------------------------------------------------------------
-- Theme & font
--------------------------------------------------------------------------------
-- No color_scheme set -> WezTerm's built-in palette, with a forced black bg.
config.colors = { background = "#000000" }

-- JetBrains Mono ships with WezTerm (zero installs); Nerd Symbols fallback.
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"Symbols Nerd Font Mono", -- harmless if not installed
})
config.font_size = 11.5

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 } -- edge-to-edge
config.adjust_window_size_when_changing_font_size = false
config.audible_bell = "Disabled"
config.window_close_confirmation = "NeverPrompt" -- Zellij holds the session
config.canonicalize_pasted_newlines = "CarriageReturn" -- safer multi-line paste
config.warn_about_missing_glyphs = false -- no font-fallback popups

-- Rendering: modern GPU backend + higher refresh for smoother scrolling.
config.front_end = "WebGpu"
config.max_fps = 120

-- No tab bar -- Zellij handles tabs/panes, so WezTerm stays bare.
config.enable_tab_bar = false
config.scrollback_lines = 10000

--------------------------------------------------------------------------------
-- Keybindings
--------------------------------------------------------------------------------
-- Honor the Kitty keyboard protocol. Without this, WezTerm sends legacy
-- encoding where Ctrl+V and Ctrl+Shift+V are the SAME byte (0x16), so apps
-- (e.g. Claude Code) cannot bind Ctrl+Shift+V distinctly. Defaults to false.
config.enable_kitty_keyboard = true

-- Fullscreen remapped to F11; WezTerm's default Alt+Enter fullscreen disabled
-- so Alt+Enter is left free.
config.keys = {
	{ key = "F11", action = wezterm.action.ToggleFullScreen },
	{ key = "Enter", mods = "ALT", action = wezterm.action.DisableDefaultAssignment },
	-- Paste with Ctrl+V (default is Ctrl+Shift+V).
	{ key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
	-- Let Ctrl+Shift+V pass through to the app (Claude uses it for image paste)
	-- instead of WezTerm's built-in clipboard paste.
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
}

--------------------------------------------------------------------------------
-- Start maximized
--------------------------------------------------------------------------------
-- gui-startup fires once on launch; maximize() keeps the title bar (unlike
-- fullscreen on F11). New windows spawned later also start maximized.
wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return config
```

Replace `WSL:Ubuntu` if your distro is named differently — check with
`echo $WSL_DISTRO_NAME` inside WSL. WezTerm auto-generates one domain per distro
named `WSL:<distro>`.

## What each setting does

| Setting | Effect |
|---|---|
| `default_domain = "WSL:Ubuntu"` | Every window opens in Ubuntu/zsh, not cmd/PowerShell |
| `colors.background = "#000000"` | Pure black background (no color scheme set) |
| `font` | Built-in JetBrains Mono + Nerd Symbols fallback (zero installs) |
| `window_close_confirmation = "NeverPrompt"` | No close dialog — Zellij keeps the session alive |
| `canonicalize_pasted_newlines` | Safer multi-line paste (no accidental execution) |
| `warn_about_missing_glyphs = false` | Silences font-fallback popups |
| `front_end = "WebGpu"` + `max_fps = 120` | Modern GPU backend, smoother scrolling |
| `enable_tab_bar = false` | No tab bar — Zellij owns tabs/panes |
| `enable_kitty_keyboard = true` | Sends modifier-aware key sequences so apps can tell `Ctrl+Shift+V` from `Ctrl+V` (default is `false`) |
| `Ctrl+V` | Paste clipboard text (WezTerm default is `Ctrl+Shift+V`) |
| `Ctrl+Shift+V` | Passed through to the app — Claude Code uses it for **image paste** |
| `F11` | Toggle fullscreen (Alt+Enter default disabled, left free) |
| `gui-startup` handler | Window opens maximized (title bar kept) |

## Verify

From a WSL session, validate the config parses and inspect effective keys:

```bash
wezterm.exe --config-file 'C:\Users\<you>\.wezterm.lua' show-keys
```

A clean exit with a key list means the config is valid. WezTerm picks up
changes on save while running.

## Notes

- **`Shift+Enter` in Claude Code / TUIs:** WezTerm does not send a distinct
  sequence for `Shift+Enter` by default, so it submits instead of inserting a
  newline. With the default `Alt+Enter` fullscreen binding disabled (as above),
  **`Alt+Enter` inserts a newline** in Claude Code with no extra settings. For a
  dedicated `Shift+Enter`, add:
  `{ key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\x1b\r") }`.
- **Image paste in Claude Code (WSL):** the `enable_kitty_keyboard = true` line
  plus the `Ctrl+V` / `Ctrl+Shift+V` key bindings above are **mandatory** for
  pasting images into Claude Code under WSL — they are one half of a two-part
  setup. The matching Claude-side keybinding is documented in
  [Claude Code installation](claude_installation.md#image-paste-in-wsl-mandatory).
  Without both halves, `Ctrl+Shift+V` reaches Claude as the same byte as
  `Ctrl+V` and image paste silently does nothing.
- **`front_end = "WebGpu"`** rarely misbehaves on older/virtualized GPUs. If you
  see rendering glitches or a blank window, change that one line to `"OpenGL"`.
- **`gui-startup`** only fires on a cold start (no existing WezTerm process); it
  will not retroactively maximize an already-open window.
