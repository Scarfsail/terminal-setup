# fzf Installation

Official pages:

- <https://github.com/junegunn/fzf>

`fzf` is a general-purpose fuzzy finder for the terminal. It integrates with shell
history, file search, and tab completion, and is used as a backbone by several
other tools (e.g. [zoxide](zoxide_installation.md)'s `zi`, and the
[fzf-tab](fzf_tab_completion.md) completion picker).

## Install via apt

```bash
if command -v fzf >/dev/null 2>&1; then
  echo "fzf already installed: $(fzf --version)"
else
  sudo apt update && sudo apt install -y fzf
fi
```

> The key-binding/completion integration below needs **fzf ≥ 0.48** (for
> `fzf --zsh`). Check with `fzf --version`. If apt ships something older, install
> the upstream binary instead: <https://github.com/junegunn/fzf/releases>.

## Shell integration (native — no plugin)

This setup does **not** use `fzf-zsh-plugin` (or any framework plugin). Modern fzf
ships its own zsh integration; one line in `~/.zshrc` provides `Ctrl-T`, `Ctrl-R`,
`Alt-C`, and the `**<Tab>` trigger:

```zsh
eval "$(fzf --zsh)"
```

Place it **before** `fzf-tab` is sourced (see the
[migration guide](bash_to_zsh_migration.md)) so that `fzf-tab` wins the plain
`Tab` binding while fzf keeps the rest.

## Key bindings

| Binding | Action |
|---------|--------|
| `Ctrl+R` | Fuzzy search shell history |
| `Ctrl+T` | Paste a fuzzy-selected file path onto the command line |
| `Alt+C` | `cd` into a fuzzy-selected directory |

## Fuzzy `**<Tab>` trigger

fzf's native completion adds a `**` trigger:

```zsh
ssh **<Tab>          # pick a host
kill -9 **<Tab>      # pick a process
export **<Tab>       # pick an env var
```

> Because [fzf-tab](fzf_tab_completion.md) takes over plain `Tab`, the `**<Tab>`
> trigger is mostly superseded for file/dir completion — plain `Tab` and `Ctrl-T`
> cover those. Rebind with `FZF_COMPLETION_TRIGGER` if you want a different
> sequence.

## Optional enhancements

Richer previews inside fzf-driven pickers:

- `bat` (Debian/Ubuntu binary is `batcat`) — syntax-highlighted file previews
- `eza` — directory listings (used by [fzf-tab previews](fzf_tab_completion.md))
- `ripgrep` (`rg`) — faster file search

## Verify

```bash
fzf --version          # expect >= 0.48
# In an interactive shell, Ctrl+R should open history search:
zsh -ic 'bindkey "^R"'  # -> fzf-history-widget
```
