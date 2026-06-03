# Starship Prompt Installation

Official project: <https://starship.rs/>

[Starship](https://starship.rs/) is the prompt used in this setup. It replaced the
old Oh My Zsh `agnoster` theme when the shell moved to a
[framework-free `~/.zshrc`](bash_to_zsh_migration.md). It's a single fast binary
configured by one TOML file.

## Install (user-level, no sudo)

The reviewed machine installs starship into `~/.local/bin` (already on `PATH`):

```bash
if command -v starship >/dev/null 2>&1; then
  echo "starship already installed: $(starship --version | head -n1)"
else
  curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
fi
```

## Shell integration

Add to `~/.zshrc` (near the other tool `eval`s — see the
[migration guide](bash_to_zsh_migration.md)):

```zsh
eval "$(starship init zsh)"
```

## Theme: the repo is the source of truth

The active theme is **version-controlled in this repo** at
[`config/starship.toml`](config/starship.toml) and **symlinked** into place, so
editing it in either location updates the live prompt:

```bash
mkdir -p ~/.config
# back up any existing real file first
[ -e ~/.config/starship.toml ] && [ ! -L ~/.config/starship.toml ] && \
  mv ~/.config/starship.toml ~/.config/starship.toml.bak
ln -sfn "$HOME/dev/terminal-setup/config/starship.toml" ~/.config/starship.toml
```

Verify the link:

```bash
readlink ~/.config/starship.toml   # -> .../terminal-setup/config/starship.toml
```

### What the theme renders

A one-line powerline prompt:

- a **directory** block (dark blue), repo-relative with `…/` truncation and a few
  Nerd-Font directory-name icon substitutions;
- a connected **git** block (gold) showing the branch (`` symbol) and
  `git_status` change counts;
- per-language version segments (node, rust, go, python, java, …) that appear only
  inside a matching project;
- a clock segment.

Powerline separators are drawn with `` (U+E0B0).

> **Editing the TOML:** the powerline separators and icons are Private-Use-Area
> Nerd-Font glyphs. Some editors silently strip them. If a glyph turns into an
> empty `[]` or a blank, re-insert it by codepoint (e.g. a Python heredoc using
> `chr(0xE0B0)`) and confirm with `od -An -tx1` (expect `ee 82 b0`).

## Nerd Font requirement

The separators and icons only render with a **Nerd Font** in the terminal. This
setup uses WezTerm with a `Cascadia Code NF` fallback — see
[WezTerm setup](wezterm_windows_setup.md). Without a Nerd Font, glyphs show as
boxes or blanks (the prompt still works, it just looks wrong).

## Verify

```bash
starship --version
readlink ~/.config/starship.toml
# Render the prompt once (ANSI escapes expected):
starship prompt
```
