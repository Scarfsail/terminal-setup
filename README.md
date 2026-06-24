# terminal-setup

Short, human-readable setup guides for a WSL Ubuntu/Debian terminal environment. The repository is meant to help an AI coding assistant or a human apply a consistent terminal setup without rewriting everything from scratch.

The guides are written to be **idempotent**: they are intended to be safe to follow on machines that already have some of the tools installed.

## How to use this repo

Use it with GitHub Copilot CLI, Claude Code, or another coding agent that can read the repository and execute terminal steps.

Tell the agent what you want to set up, for example:

- "Set up this machine using the guides in `terminal-setup`."
- "Install git, Python, lazygit and fnm from this repo's instructions."

The main entry point is [`terminal_tools_setup.md`](terminal_tools_setup.md), which describes the recommended setup order.

## Tools covered

- [zsh](https://www.zsh.org/): **framework-free** shell migration from bash (no Oh My Zsh) — plugins cloned to `~/.zsh/plugins` and sourced directly ([guide](bash_to_zsh_migration.md)).
- [starship](https://starship.rs/): the prompt (replaces the old `agnoster` theme); theme is version-controlled and symlinked from this repo ([guide](starship_installation.md)).
- [WezTerm](https://wezfurlong.org/wezterm/): GPU terminal emulator on Windows that opens into WSL ([guide](wezterm_windows_setup.md)).
- [Zellij](https://zellij.dev/): terminal multiplexer for persistent sessions, panes, and window-based workflows.
- [Midnight Commander](https://midnight-commander.org/): classic terminal file manager for quick navigation and file operations.
- [lazygit](https://github.com/jesseduffield/lazygit): lightweight terminal UI for common Git workflows.
- [Fresh](https://getfresh.dev/): minimal terminal editor with a simple upstream install path.
- [fnm](https://github.com/Schniz/fnm): fast Node.js version manager.
- [Git](https://git-scm.com/): source control tooling and CLI setup.
- [Python](https://www.python.org/): Python runtime and related terminal usage baseline.
- [glow](https://github.com/charmbracelet/glow): terminal Markdown renderer (installed via snap; see [Snap PATH setup](snap_path_setup.md) if `/snap/bin` is missing from `PATH`).
- [fzf](https://github.com/junegunn/fzf): fuzzy finder for history, files, and tab completion, wired up via fzf's native shell integration (`fzf --zsh`).
- [fzf-tab](https://github.com/Aloxaf/fzf-tab): replaces zsh's `Tab` completion menu with an fzf picker and preview pane ([guide](fzf_tab_completion.md)).
- [eza](https://github.com/eza-community/eza): modern `ls` replacement; backs the `ls`/`ll`/`lt`/`tree` aliases and the directory previews used by `fzf-tab` ([guide](eza_installation.md)).
- [zoxide](https://github.com/ajeetdsouza/zoxide): smarter `cd` that tracks frecency and lets you jump to directories with short fuzzy abbreviations.
- [Claude Code](https://www.anthropic.com/claude-code): Anthropic's terminal coding agent, including the WSL image-paste setup ([guide](claude_installation.md)).

## Repo-managed configs & scripts

Machine-independent configs and helper scripts live in the repo as the single
source of truth (most are symlinked into place — see the table in
[`terminal_tools_setup.md`](terminal_tools_setup.md#repo-managed-configs-single-source-of-truth)):

- [`config/zsh/`](config/zsh/) — sharable zsh config (history, options, keybindings, completion, fzf/fzf-tab, env, aliases, eza), sourced from `~/.zshrc` ([migration guide](bash_to_zsh_migration.md#4-assemble-zshrc)).
- [`config/starship.toml`](config/starship.toml) — starship prompt theme (symlinked to `~/.config/starship.toml`).
- [`config/zellij/config.kdl`](config/zellij/config.kdl) — Zellij keybinds/config (symlinked).
- [`config/lazygit/config.yml`](config/lazygit/config.yml) — lazygit `delta` pager config (symlinked).
- [`config/wezterm/wezterm.lua`](config/wezterm/wezterm.lua) — WezTerm config reference copy (Windows side; can't be symlinked across the WSL↔Windows boundary).
- [`scripts/wsl/xdg-open`](scripts/wsl/xdg-open) — WSL→Windows browser wrapper used as `$BROWSER` (symlinked to `~/.local/bin/xdg-open`).
- [`scripts/fzf/eza-fzf-preview`](scripts/fzf/eza-fzf-preview) — directory preview for fzf-tab.
- [`scripts/zellij/zellij-auto-start`](scripts/zellij/zellij-auto-start) — interactive Zellij session launcher.

`~/.zshrc` is **not** tracked (it varies per machine); its reference content is in
the [migration guide](bash_to_zsh_migration.md). Secrets stay in `~/.config/secrets/`.
