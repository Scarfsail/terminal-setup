# Terminal Tools Setup Guide

This is the master guide for the current WSL Ubuntu/Debian terminal setup.

Every guide in this repository is meant to be **idempotent**: safe to follow on a machine that has none, some, or all of the tools already installed. Package-manager commands may be re-run, and config steps are written to preserve existing user files unless a guide explicitly tells you to replace something.

## Recommended order

1. [Bash to Zsh migration](bash_to_zsh_migration.md)
2. Ask the user which terminal multiplexer they prefer: [tmux](tmux_installation.md) or [Zellij](zellij_installation.md)
3. If they choose tmux, continue with [tmux installation](tmux_installation.md)
4. If they choose tmux, continue with [Oh My Tmux installation](oh_my_tmux_installation.md)
5. If they choose tmux, continue with [`.tmux.conf.local` overrides](tmux_conf_local_overrides.md)
6. If they choose tmux, continue with [WSL clipboard integration](wsl_clipboard_integration.md)
7. If they choose tmux, continue with [tmux Copilot status integration](tmux_copilot_status_integration.md)
8. If they choose tmux, continue with [tmux Claude Code status integration](tmux_claude_status_integration.md)
9. [Midnight Commander installation](midnight_commander_installation.md)
10. [lazygit installation](lazygit_installation.md)
11. [Fresh editor installation](fresh_editor_installation.md)
12. [fnm installation](fnm_installation.md)
13. [git installation](git_installation.md)
14. [Python installation](python_installation.md)
15. [Snap PATH setup](snap_path_setup.md) (only needed if you plan to install snap packages such as `glow`)
16. [glow installation](glow_installation.md)

## Multiplexer choice

Before starting any terminal multiplexer setup, ask the user whether they prefer **tmux** or **Zellij**.

- If they choose **tmux**, follow:
  - [tmux installation](tmux_installation.md)
  - [Oh My Tmux installation](oh_my_tmux_installation.md)
  - [`.tmux.conf.local` overrides](tmux_conf_local_overrides.md)
  - [WSL clipboard integration](wsl_clipboard_integration.md)
  - [tmux Copilot status integration](tmux_copilot_status_integration.md)
  - [tmux Claude Code status integration](tmux_claude_status_integration.md)
- If they choose **Zellij**, follow:
  - [Zellij installation](zellij_installation.md)

The tmux status integrations in this repository are tmux-specific and should only be applied when the user chose tmux.

## Shared assumptions

- Platform: WSL Ubuntu/Debian, apt-based
- Shell target: `zsh` with Oh My Zsh
- User-level binaries should remain reachable through `~/.local/bin`
- Use upstream install methods where they provide a better result than the distro package
- Prefer creating missing config and skipping existing config over blindly overwriting files

## First-time bootstrap

Install the packages that several of the guides rely on:

```bash
sudo apt update
sudo apt install -y curl git unzip ca-certificates
```

## Notes on what is already present on the reviewed machine

At the time this documentation was reviewed, the machine already had:

- `zsh` + Oh My Zsh
- `tmux`
- `zellij`
- `mc` (Midnight Commander)
- `lazygit`
- `fresh`
- `fnm`
- `git`
- `python3`

The tmux setup on the reviewed machine is:

- Oh My Tmux installed in `~/.local/share/tmux/oh-my-tmux`
- `~/.config/tmux/tmux.conf` symlinked to the upstream `.tmux.conf`
- `~/.config/tmux/tmux.conf.local` used for local overrides
- TPM-managed plugins stored in `~/.config/tmux/plugins`
- active plugin: `omerxx/tmux-floax`
