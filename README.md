# terminal-setup

Short, human-readable setup guides for a WSL Ubuntu/Debian terminal environment. The repository is meant to help an AI coding assistant or a human apply a consistent terminal setup without rewriting everything from scratch.

The guides are written to be **idempotent**: they are intended to be safe to follow on machines that already have some of the tools installed.

## How to use this repo

Use it with GitHub Copilot CLI, Claude Code, or another coding agent that can read the repository and execute terminal steps.

Tell the agent what you want to set up, for example:

- "Set up this machine using the guides in `terminal-setup`, and ask me whether I want tmux or Zellij."
- "Install git, Python, lazygit and fnm from this repo's instructions."
- "Apply the tmux setup including Oh My Tmux, local overrides, clipboard integration, and Copilot/Claude status."

The main entry point is [`terminal_tools_setup.md`](terminal_tools_setup.md), which describes the recommended order and the tmux vs. Zellij branch.

## Tools covered

- [zsh](https://www.zsh.org/) + [Oh My Zsh](https://ohmyz.sh/): shell migration from bash to a more ergonomic interactive shell setup.
- [tmux](https://github.com/tmux/tmux/wiki): terminal multiplexer for persistent sessions, panes, and window-based workflows.
- [Oh My Tmux](https://github.com/gpakosz/.tmux): opinionated tmux base config used here as the upstream foundation.
- [Zellij](https://zellij.dev/): alternative terminal multiplexer for users who prefer it over tmux.
- [Midnight Commander](https://midnight-commander.org/): classic terminal file manager for quick navigation and file operations.
- [lazygit](https://github.com/jesseduffield/lazygit): lightweight terminal UI for common Git workflows.
- [Fresh](https://getfresh.dev/): minimal terminal editor with a simple upstream install path.
- [fnm](https://github.com/Schniz/fnm): fast Node.js version manager.
- [Git](https://git-scm.com/): source control tooling and CLI setup.
- [Python](https://www.python.org/): Python runtime and related terminal usage baseline.
- [glow](https://github.com/charmbracelet/glow): terminal Markdown renderer (installed via snap; see [Snap PATH setup](snap_path_setup.md) if `/snap/bin` is missing from `PATH`).

## Customizations included

- tmux setup based on Oh My Tmux, with local overrides kept separate from the upstream config.
- WSL clipboard integration for tmux copy operations.
- tmux quality-of-life defaults such as mouse support, retaining the current path in new panes, and plugin auto-management.
- [`omerxx/tmux-floax`](https://github.com/omerxx/tmux-floax) enabled as the tracked tmux popup/scratchpad plugin.
- Pane-aware tmux status integrations for [GitHub Copilot CLI](https://github.com/github/copilot-cli) and [Claude Code](https://docs.anthropic.com/), so the status bar follows the active pane and shows useful context usage.
