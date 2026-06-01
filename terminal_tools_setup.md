# Terminal Tools Setup Guide

This is the master guide for the current WSL Ubuntu/Debian terminal setup.

Every guide in this repository is meant to be **idempotent**: safe to follow on a machine that has none, some, or all of the tools already installed. Package-manager commands may be re-run, and config steps are written to preserve existing user files unless a guide explicitly tells you to replace something.

## Recommended order

1. [Bash to Zsh migration](bash_to_zsh_migration.md)
2. [fzf Tab completion setup](fzf_tab_completion.md) (fzf-tab + `eza` previews)
3. [Zellij installation](zellij_installation.md)
4. [Midnight Commander installation](midnight_commander_installation.md)
5. [lazygit installation](lazygit_installation.md)
6. [Fresh editor installation](fresh_editor_installation.md)
7. [fnm installation](fnm_installation.md)
8. [git installation](git_installation.md)
9. [Python installation](python_installation.md)
10. [Snap PATH setup](snap_path_setup.md) (only needed if you plan to install snap packages such as `glow`)
11. [glow installation](glow_installation.md)
12. [netwatch installation](netwatch_installation.md)

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

- `zsh` + Oh My Zsh (with `fzf-tab` Tab completion and `eza` previews)
- `zellij`
- `mc` (Midnight Commander)
- `lazygit`
- `fresh`
- `fnm`
- `git`
- `python3`
