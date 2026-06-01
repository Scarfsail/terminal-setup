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

- [zsh](https://www.zsh.org/) + [Oh My Zsh](https://ohmyz.sh/): shell migration from bash to a more ergonomic interactive shell setup.
- [Zellij](https://zellij.dev/): terminal multiplexer for persistent sessions, panes, and window-based workflows.
- [Midnight Commander](https://midnight-commander.org/): classic terminal file manager for quick navigation and file operations.
- [lazygit](https://github.com/jesseduffield/lazygit): lightweight terminal UI for common Git workflows.
- [Fresh](https://getfresh.dev/): minimal terminal editor with a simple upstream install path.
- [fnm](https://github.com/Schniz/fnm): fast Node.js version manager.
- [Git](https://git-scm.com/): source control tooling and CLI setup.
- [Python](https://www.python.org/): Python runtime and related terminal usage baseline.
- [glow](https://github.com/charmbracelet/glow): terminal Markdown renderer (installed via snap; see [Snap PATH setup](snap_path_setup.md) if `/snap/bin` is missing from `PATH`).
- [fzf](https://github.com/junegunn/fzf): fuzzy finder for history, files, and tab completion, wired up via the `fzf-zsh-plugin` Oh My Zsh plugin.
- [fzf-tab](https://github.com/Aloxaf/fzf-tab): replaces zsh's `Tab` completion menu with an fzf picker and preview pane ([guide](fzf_tab_completion.md)).
- [eza](https://github.com/eza-community/eza): modern `ls` replacement; provides the directory previews used by `fzf-tab`.
- [zoxide](https://github.com/ajeetdsouza/zoxide): smarter `cd` that tracks frecency and lets you jump to directories with short fuzzy abbreviations.
- [Claude Code](https://www.anthropic.com/claude-code): Anthropic's terminal coding agent, including the WSL image-paste setup ([guide](claude_installation.md)).

## Customizations included

- Zellij auto-start script for interactive session launching.
