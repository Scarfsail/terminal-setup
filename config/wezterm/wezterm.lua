-- ~/.wezterm.lua  (Windows: C:\Users\ondre\.wezterm.lua)
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

-- JetBrains Mono ships with WezTerm (zero installs) for normal text;
-- Cascadia Code NF (installed per-user) supplies the Nerd Font glyphs
-- (powerline separators, git branch symbol, icons) used by the starship prompt.
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"Cascadia Code NF", -- Nerd Font fallback for powerline/git/icon glyphs
	"Symbols Nerd Font Mono", -- harmless if not installed
})
config.font_size = 11.5

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
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

config.default_cursor_style = 'SteadyBar'
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
