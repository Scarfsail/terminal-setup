# zoxide Installation

Official pages:

- <https://github.com/ajeetdsouza/zoxide>

`zoxide` is a smarter `cd` command that tracks your most-visited directories and lets you jump to them with a short fuzzy abbreviation instead of a full path.

## Install via apt

```bash
if command -v zoxide >/dev/null 2>&1; then
  echo "zoxide already installed: $(zoxide --version)"
else
  sudo apt update && sudo apt install -y zoxide
fi
```

> The apt package may lag behind upstream. For the latest version install via the official installer instead:
> ```bash
> curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
> ```

## Shell integration

Add the following to `~/.zshrc` (with the other tool `eval`s):

```zsh
eval "$(zoxide init zsh)"
```

This creates the `z` command (and optionally `zi` for interactive mode) and hooks into `cd` to track visited directories.

## Basic usage

```zsh
z foo          # jump to the highest-ranked directory matching "foo"
z foo bar      # jump to highest-ranked match for both "foo" and "bar"
z -            # jump to the previous directory
zi             # open an interactive fzf picker over your history
```

`z` replaces `cd` for navigation — use it exactly like `cd` but with fuzzy abbreviations.

## Interactive picker (`zi`)

`zi` opens an [fzf](fzf_installation.md)-powered picker over your directory history. Requires `fzf` to be installed.

```zsh
zi             # pick a directory interactively
```

## How ranking works

zoxide scores directories based on **frecency** (frequency × recency). The more often and more recently you visit a directory, the higher it ranks. Rankings update automatically every time you `cd` into a directory.

## Useful extras

```zsh
zoxide query foo        # show what z foo would jump to, without jumping
zoxide query -l foo     # list all matches ranked
zoxide remove /path     # remove a directory from the database
```

## Verify

```bash
zoxide --version
```

After a few `cd` commands in a new shell, test:

```bash
z <partial-directory-name>
```
