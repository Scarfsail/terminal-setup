# Terminal Tools Setup Guide

This is the master guide for the current WSL Ubuntu/Debian terminal setup.

Every guide in this repository is meant to be **idempotent**: safe to follow on a machine that has none, some, or all of the tools already installed. Package-manager commands may be re-run, and config steps are written to preserve existing user files unless a guide explicitly tells you to replace something.

## Recommended order

1. [Bash to Zsh migration](bash_to_zsh_migration.md) (framework-free `~/.zshrc` + plugins)
2. [Starship prompt](starship_installation.md) (prompt + repo-managed theme)
3. [fzf installation](fzf_installation.md) (native shell integration)
4. [fzf Tab completion setup](fzf_tab_completion.md) (fzf-tab + `eza` previews)
5. [Zellij installation](zellij_installation.md)
6. [Midnight Commander installation](midnight_commander_installation.md)
7. [lazygit installation](lazygit_installation.md)
8. [Fresh editor installation](fresh_editor_installation.md)
9. [fnm installation](fnm_installation.md)
10. [git installation](git_installation.md)
11. [Python installation](python_installation.md)
12. [zoxide installation](zoxide_installation.md)
13. [Snap PATH setup](snap_path_setup.md) (only needed if you plan to install snap packages such as `glow`)
14. [glow installation](glow_installation.md)
15. [netwatch installation](netwatch_installation.md)
16. [WezTerm on Windows](wezterm_windows_setup.md) (the host terminal emulator)

## Shared assumptions

- Platform: WSL Ubuntu/Debian, apt-based
- Shell target: **framework-free `zsh`** (no Oh My Zsh) with the [starship](starship_installation.md) prompt
- User-level binaries should remain reachable through `~/.local/bin`
- Use upstream install methods where they provide a better result than the distro package
- Prefer creating missing config and skipping existing config over blindly overwriting files

## Repo-managed configs (single source of truth)

Machine-independent configs live in this repo and are **symlinked** into place, so
editing them here updates the live tool:

| Repo path | Symlinked to | Guide |
|---|---|---|
| [`config/starship.toml`](config/starship.toml) | `~/.config/starship.toml` | [starship](starship_installation.md) |
| [`config/zellij/config.kdl`](config/zellij/config.kdl) | `~/.config/zellij/config.kdl` | [zellij](zellij_installation.md) |
| [`config/lazygit/config.yml`](config/lazygit/config.yml) | `~/.config/lazygit/config.yml` | [lazygit](lazygit_installation.md) |
| [`scripts/wsl/xdg-open`](scripts/wsl/xdg-open) | `~/.local/bin/xdg-open` | (WSL browser wrapper, used as `$BROWSER`) |
| [`scripts/fzf/eza-fzf-preview`](scripts/fzf/eza-fzf-preview) | *(referenced by path)* | [fzf-tab](fzf_tab_completion.md) |
| [`scripts/zellij/zellij-auto-start`](scripts/zellij/zellij-auto-start) | *(referenced by path)* | [zellij](zellij_installation.md) |
| [`config/wezterm/wezterm.lua`](config/wezterm/wezterm.lua) | *(reference copy — Windows side)* | [WezTerm](wezterm_windows_setup.md) |

`~/.zshrc` is intentionally **not** in the repo (it varies per machine); the
[migration guide](bash_to_zsh_migration.md) documents its reference content.
Secrets live in `~/.config/secrets/*.env` and are never committed.

## First-time bootstrap

Install the packages that several of the guides rely on:

```bash
sudo apt update
sudo apt install -y curl git unzip ca-certificates
```

## Notes on what is already present on the reviewed machine

At the time this documentation was reviewed, the machine already had:

- framework-free `zsh` (plugins under `~/.zsh/plugins`) with the `starship` prompt
- `fzf` (native integration) + `fzf-tab` Tab completion + `eza` previews
- `zellij`
- `mc` (Midnight Commander)
- `lazygit`
- `fresh`
- `fnm`
- `git`
- `python3`
- `zoxide`
