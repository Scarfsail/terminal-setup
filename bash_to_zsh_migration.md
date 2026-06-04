# Bash to Zsh Migration Guide (WSL Ubuntu/Debian)

This reflects the current shell setup, which is **framework-free** (no Oh My Zsh):

- `zsh` is the default shell
- the interactive config is a hand-written `~/.zshrc` (no framework loader)
- the prompt is [starship](starship_installation.md) (replaces the old `agnoster` theme)
- three zsh plugins are cloned to `~/.zsh/plugins` and `source`d directly:
  `zsh-autosuggestions`, `fzf-tab`, `zsh-syntax-highlighting`
- `fzf` uses its **native** shell integration (`eval "$(fzf --zsh)"`), not a plugin
- `compinit` is cached (full security audit at most once per day)
- `fnm` is used instead of `nvm`
- `~/.local/bin` is kept on `PATH`

> `~/.zshrc` itself is **not** version-controlled in this repo — it tends to differ
> per machine. Treat the blocks below as the reference content to assemble. The
> shared, machine-independent pieces *are* in the repo: the [starship theme](starship_installation.md),
> the [fzf-tab preview script and `eza` previews](fzf_tab_completion.md), and the
> [Zellij auto-start helper](zellij_installation.md).

The commands below are written to be safe to re-run.

## 1. Install base packages

```bash
sudo apt update
sudo apt install -y zsh git curl unzip
```

## 2. Set Zsh as the default shell

```bash
if [ "$(basename "$SHELL")" != "zsh" ]; then
  chsh -s "$(command -v zsh)"
  echo "Default shell changed to zsh. Sign out and back in if the current session stays on bash."
else
  echo "zsh is already the default shell"
fi
```

## 3. Install the plugins into `~/.zsh/plugins`

No framework is used; the plugins are plain git clones that the `.zshrc` sources
by path.

```bash
ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"

[ -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ] || \
  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"

[ -d "$ZSH_PLUGIN_DIR/fzf-tab" ] || \
  git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$ZSH_PLUGIN_DIR/fzf-tab"

[ -d "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" ] || \
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
```

Update later with `git -C <dir> pull` per plugin.

## 4. Assemble `~/.zshrc`

The machine-independent pieces live in this repo under
[`config/zsh/`](config/zsh/) and are **sourced** from `~/.zshrc`, so they have one
source of truth and `~/.zshrc` stays thin and per-machine. The shared files are:

| File | Contents |
|---|---|
| [`config/zsh/history.zsh`](config/zsh/history.zsh) | `HISTFILE`/sizes + history `setopt`s |
| [`config/zsh/options.zsh`](config/zsh/options.zsh) | `auto_cd`, `auto_pushd`, `interactive_comments`, … |
| [`config/zsh/completion.zsh`](config/zsh/completion.zsh) | cached `compinit` + completion styling |
| [`config/zsh/fzf.zsh`](config/zsh/fzf.zsh) | `fzf --zsh` + all fzf-tab `zstyle`s (preview path auto-resolved) |
| [`config/zsh/env.zsh`](config/zsh/env.zsh) | `EDITOR`/`VISUAL` + `BROWSER` + wrapper |
| [`config/zsh/aliases.zsh`](config/zsh/aliases.zsh) | `glow`, `bat`, `python` |
| [`config/zsh/eza.zsh`](config/zsh/eza.zsh) | `ls`/`l`/`ll`/`la`/`lt`/`tree` eza aliases (see [eza](eza_installation.md)) |

`~/.zshrc` itself keeps only machine-specific bits (PATH, plugin sourcing, tool
init, secrets, Zellij auto-start) and sources the shared files in order:

```zsh
TERMINAL_SETUP="$HOME/dev/terminal-setup"

# --- PATH (machine-specific) ------------------------------------------------
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
[ -d /snap/bin ] && case ":$PATH:" in *":/snap/bin:"*) ;; *) export PATH="$PATH:/snap/bin" ;; esac
export PATH="$HOME/.local/share/fnm:$PATH"   # fnm

# --- shared config (one source of truth in terminal-setup/config/zsh) -------
source "$TERMINAL_SETUP/config/zsh/history.zsh"
source "$TERMINAL_SETUP/config/zsh/options.zsh"
source "$TERMINAL_SETUP/config/zsh/completion.zsh"  # cached compinit + styling
source "$TERMINAL_SETUP/config/zsh/fzf.zsh"         # fzf + fzf-tab (before plugins)

# --- plugins (installed locally under ~/.zsh/plugins; order matters) --------
ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"
source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_PLUGIN_DIR/fzf-tab/fzf-tab.plugin.zsh"
source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"  # MUST be last

# --- tool init --------------------------------------------------------------
eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# --- shared env + aliases ---------------------------------------------------
source "$TERMINAL_SETUP/config/zsh/env.zsh"
source "$TERMINAL_SETUP/config/zsh/aliases.zsh"
source "$TERMINAL_SETUP/config/zsh/eza.zsh"         # eza ls/tree aliases

# --- secrets (machine-specific; kept out of the repo) -----------------------
for secret in "$HOME"/.config/secrets/*.env; do
  [ -f "$secret" ] && . "$secret"
done

# --- Zellij auto-start (interactive shells only) ----------------------------
[[ -o interactive ]] && "$TERMINAL_SETUP/scripts/zellij/zellij-auto-start"

# --- local machine-specific additions below --------------------------------
```

Key ordering rules:

- `completion.zsh` (which runs `compinit`) is sourced **before** `fzf-tab`.
- `fzf.zsh` (which runs `fzf --zsh`) is sourced **before** `fzf-tab` so fzf-tab
  wins the `Tab` binding.
- `zsh-syntax-highlighting` is sourced **last**.

> **Secrets:** never inline tokens in `~/.zshrc`. Keep them in
> `~/.config/secrets/*.env` (e.g. `chmod 600`), which the loop above sources when
> present. That directory is not part of this repo.

> **`compinit` caching:** `config/zsh/completion.zsh` runs the full security audit
> at most once per day, then `touch`es `~/.zcompdump` so the 24-hour clock resets
> (compinit won't rewrite an unchanged dump, so without the `touch` every startup
> would re-run the ~250 ms `compaudit`).

## 5. Prompt and per-tool integration

- **Prompt:** see [starship installation](starship_installation.md) — install the
  binary and symlink the repo-managed theme.
- **fzf-tab previews + `eza`:** see [fzf Tab completion setup](fzf_tab_completion.md).
- **fnm:** see [fnm installation](fnm_installation.md).
- **zoxide:** see [zoxide installation](zoxide_installation.md).

## 6. `.bashrc` fallback (optional)

If you keep a bash fallback during the transition, mirror only the essentials:

```bash
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/fnm:$PATH"
command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd --shell bash)"
```

## 7. Reload the shell

```bash
exec zsh
```

## Verification

```bash
echo "Shell: $SHELL"; zsh --version
ls ~/.zsh/plugins                                  # the three plugins
grep -q 'oh-my-zsh' ~/.zshrc && echo "OMZ STILL REFERENCED" || echo "framework-free ✓"
zsh -ic 'bindkey "^I"'                             # Tab -> fzf-tab-complete
zsh -ic '(( $+functions[_zsh_autosuggest_start] )) && echo autosuggest:ok'
command -v starship && command -v fnm
```
