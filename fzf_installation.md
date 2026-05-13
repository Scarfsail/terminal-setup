# fzf Installation

Official pages:

- <https://github.com/junegunn/fzf>

`fzf` is a general-purpose fuzzy finder for the terminal. It integrates with shell history, file search, and tab completion, and is used as a backbone by several other tools and plugins.

## Install via apt

```bash
if command -v fzf >/dev/null 2>&1; then
  echo "fzf already installed: $(fzf --version)"
else
  sudo apt update && sudo apt install -y fzf
fi
```

## Oh My Zsh plugin (fzf-zsh-plugin)

The bare `fzf` binary has no shell integration by default. The [`fzf-zsh-plugin`](https://github.com/unixorn/fzf-zsh-plugin) wires it up with key bindings, completion, and a collection of helper scripts.

### 1. Clone the plugin

```bash
git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin \
  "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin"
```

### 2. Add to plugins in `~/.zshrc`

```zsh
plugins=(
  ...
  fzf-zsh-plugin   # keep this last or near-last
)
```

> The plugin dynamically sets `$FZF_DEFAULT_COMMAND` based on what tools (e.g. `rg`, `bat`) are on your `$PATH`, so it should load after other plugins have extended `$PATH`.

### 3. Create the plugin config directory

Because `fzf` was installed via apt (not the fzf install script), the `~/.fzf/` directory does not exist. Create it so the plugin can write its settings there:

```bash
mkdir -p ~/.fzf
cp "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin/fzf-settings.zsh" \
   ~/.fzf/fzf.zsh
```

### 4. Source the apt completion and key-binding scripts

Add the following at the bottom of `~/.zshrc` (after `source $ZSH/oh-my-zsh.sh`):

```zsh
source /usr/share/doc/fzf/examples/completion.zsh 2>/dev/null
source /usr/share/doc/fzf/examples/key-bindings.zsh 2>/dev/null
```

This enables `**<Tab>` fuzzy completion and the `Ctrl+T` / `Alt+C` bindings that the apt package provides but does not auto-load.

## Key bindings

| Binding | Action |
|---------|--------|
| `Ctrl+R` | Fuzzy search shell history |
| `Ctrl+T` | Paste a fuzzy-selected file path onto the command line |
| `Alt+C` | `cd` into a fuzzy-selected directory |

## Fuzzy tab completion (`**<Tab>`)

Type `**` followed by Tab after any command to open an interactive fuzzy picker:

```zsh
vim **<Tab>          # pick any file
cd **<Tab>           # pick a directory
kill -9 **<Tab>      # pick a process
ssh **<Tab>          # pick a host from known_hosts
vim src/**<Tab>      # pick within src/
vim **/*.ts<Tab>     # pick only .ts files
```

The picker is context-aware: `cd` shows only directories, `kill` shows processes, etc.

## Helper scripts (from fzf-zsh-plugin)

| Command | Description |
|---------|-------------|
| `fzf-find-edit` | Fuzzy-find a file and open it in `$EDITOR` |
| `fzf-grep-edit` | Search file contents, pick a match, open in `$EDITOR` |
| `fzf-kill` | Fuzzy-select a process to kill |
| `fzf-git-checkout` | Fuzzy-pick a git branch to check out |
| `fzf-git-branch` | Output a fuzzy-selected branch name (useful in scripts) |
| `fif` | Find a search term in files (requires `rg`) |
| `pr-list` | Browse GitHub PRs with fzf (requires `gh`) |

## Optional enhancements

Install these for richer file previews inside fzf:

- `bat` — syntax-highlighted previews (`sudo apt install bat`)
- `eza` — improved directory listings
- `ripgrep` (`rg`) — faster file search, auto-detected by the plugin

## Note on zsh-autocomplete compatibility

`zsh-autocomplete` intercepts Tab aggressively and will prevent `**<Tab>` from working. If you use `fzf-zsh-plugin`, disable or remove `zsh-autocomplete` from your plugins list.

## Verify

```bash
fzf --version
# Then test in an interactive shell:
# Press Ctrl+R to open history search
```
