# eza Installation

Official pages:

- <https://github.com/eza-community/eza>
- <https://eza.rocks/>

`eza` is a modern `ls` replacement with colours, Git status columns, a tree view,
and optional [Nerd Font](https://www.nerdfonts.com/) icons. In this setup it serves
two jobs: it powers the `ls`/`ll`/`lt`/`tree` aliases, and it renders the directory
previews used by the [fzf-tab](fzf_tab_completion.md) completion picker (via
[`scripts/fzf/eza-fzf-preview`](scripts/fzf/eza-fzf-preview)).

## Install via apt

`eza` is packaged on recent Debian/Ubuntu releases:

```bash
if command -v eza >/dev/null 2>&1; then
  echo "eza already installed: $(eza --version | head -1)"
else
  sudo apt update && sudo apt install -y eza
fi
```

> If apt has no `eza` package (older releases), install the upstream binary or use
> the community apt repo — see <https://github.com/eza-community/eza/blob/main/INSTALL.md>.

## Shell aliases (repo-managed)

The aliases and the icon toggle live in this repo at
[`config/zsh/eza.zsh`](config/zsh/eza.zsh) and are sourced from `~/.zshrc` (see the
[migration guide](bash_to_zsh_migration.md#4-assemble-zshrc)), so there is one source
of truth. The whole block is guarded by `command -v eza`, so it is a no-op on a
machine that doesn't have eza yet.

Shared options applied to every alias: `--group-directories-first --git`.

| Alias | Expands to | Purpose |
|---|---|---|
| `ls` | `eza …` | plain listing |
| `l` | `eza … -lbF` | long, binary sizes, type indicators |
| `ll` | `eza … -lbhHigUmuSa --time-style=long-iso` | all details, ISO timestamps |
| `la` | `eza … -lbhHigUmuSa` | all details |
| `lt` | `eza … --tree --level=2` | tree, 2 levels deep |
| `tree` | `eza … --tree` | full tree |

`EZA_ICONS_AUTO=1` is exported so icons show when output is a terminal. They need a
**Nerd Font** in the terminal emulator (the [WezTerm config](wezterm_windows_setup.md)
already uses one); without one the icon glyphs render as tofu boxes — drop the export
or set `EZA_ICONS_AUTO=0` if you don't have a Nerd Font.

## Verify

```bash
eza --version
exec zsh                # reload so the aliases are picked up
ll                      # detailed listing with Git columns
lt                      # 2-level tree
```
