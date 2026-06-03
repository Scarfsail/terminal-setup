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

The interactive config has a few ordered sections. The full fzf-tab preview
configuration lives in the [fzf Tab completion guide](fzf_tab_completion.md); the
essential skeleton is:

```zsh
# --- PATH -------------------------------------------------------------------
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
[ -d /snap/bin ] && case ":$PATH:" in *":/snap/bin:"*) ;; *) export PATH="$PATH:/snap/bin" ;; esac
export PATH="$HOME/.local/share/fnm:$PATH"   # fnm

# --- history ----------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"; HISTSIZE=50000; SAVEHIST=50000
setopt extended_history hist_expire_dups_first hist_ignore_dups hist_ignore_space \
       hist_verify inc_append_history share_history

# --- shell options ----------------------------------------------------------
setopt auto_cd auto_pushd pushd_ignore_dups interactive_comments prompt_subst

# --- completion (cached compinit: full audit/rebuild at most once a day) -----
# Glob qualifiers don't expand inside [[ ]], so collect matches in an array.
autoload -Uz compinit
() {
  local zcd="$HOME/.zcompdump"
  local -a stale=( $zcd(N.mh+24) )
  if (( $#stale )) || [[ ! -s $zcd ]]; then compinit -d "$zcd"; else compinit -C -d "$zcd"; fi
}
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
_comp_options+=(globdots)
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# --- fzf (native integration: Ctrl-T / Ctrl-R / Alt-C / ** trigger) ---------
eval "$(fzf --zsh)"

# --- plugins (order matters) ------------------------------------------------
ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"
source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_PLUGIN_DIR/fzf-tab/fzf-tab.plugin.zsh"
# ...fzf-tab zstyles here (see fzf_tab_completion.md)...
source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"  # MUST be last

# --- tool init --------------------------------------------------------------
eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# --- env / aliases ----------------------------------------------------------
export EDITOR=fresh VISUAL=fresh
alias bat='batcat'
alias python='python3'
alias glow='glow -w $(tput cols)'

# --- secrets (kept out of the file; see ~/.config/secrets/) -----------------
for secret in atlassian azure; do
  [ -f "$HOME/.config/secrets/$secret.env" ] && . "$HOME/.config/secrets/$secret.env"
done
```

Key ordering rules:

- `compinit` runs **before** `fzf-tab` is sourced.
- `fzf --zsh` is evaluated **before** `fzf-tab` so fzf-tab wins the `Tab` binding.
- `zsh-syntax-highlighting` is sourced **last**.

> **Secrets:** never inline tokens in `~/.zshrc`. Keep them in
> `~/.config/secrets/*.env` (e.g. `chmod 600`), which the loop above sources when
> present. That directory is not part of this repo.

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
