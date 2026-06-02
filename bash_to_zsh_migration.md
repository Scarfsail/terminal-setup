# Bash to Zsh Migration Guide (WSL Ubuntu/Debian)

This version reflects the current shell setup:

- `zsh` is the default shell
- Oh My Zsh is installed under `~/.oh-my-zsh`
- the active theme is `agnoster`
- the active plugin set is `git zsh-autosuggestions fzf-zsh-plugin fzf-tab zsh-syntax-highlighting`
- Tab completion runs through fzf (see [fzf Tab completion setup](fzf_tab_completion.md))
- `fnm` is used instead of `nvm`
- `~/.local/bin` is kept on `PATH`

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

## 3. Install Oh My Zsh without replacing an existing `.zshrc`

```bash
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
else
  echo "Oh My Zsh already installed"
fi
```

## 4. Set the theme to `agnoster`

```bash
if grep -q '^ZSH_THEME=' ~/.zshrc; then
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="agnoster"/' ~/.zshrc
else
  printf '\nZSH_THEME="agnoster"\n' >> ~/.zshrc
fi
```

> `agnoster` looks best with a Nerd Font or another font that includes Powerline glyphs.

## 5. Install the current plugin set

```bash
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/fzf-zsh-plugin" ]; then
  git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git \
    "$ZSH_CUSTOM/plugins/fzf-zsh-plugin"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
  git clone --depth 1 https://github.com/Aloxaf/fzf-tab \
    "$ZSH_CUSTOM/plugins/fzf-tab"
fi
```

> `fzf-tab` and `zsh-autocomplete` both take over the `Tab` key and cannot be
> used together. This setup uses `fzf-tab`, so keep `zsh-autocomplete` out of the
> `plugins=(...)` list (the directory may stay installed on disk — Oh My Zsh only
> loads plugins named in the array; `rm -rf "$ZSH_CUSTOM/plugins/zsh-autocomplete"`
> if you want to remove it). See the
> [fzf Tab completion setup](fzf_tab_completion.md) for the full picker and
> preview configuration (and the `eza` dependency).

## 6. Make `.zshrc` match the current setup

### Plugin list

Make sure the `plugins=(...)` block in `~/.zshrc` contains these entries once:

```zsh
plugins=(
  git
  zsh-autosuggestions      # greyed-out inline suggestions from history
  fzf-zsh-plugin           # fzf binary glue: Ctrl-T / Ctrl-R / Alt-C / ** trigger
  fzf-tab                  # fzf-powered Tab completion (load AFTER fzf, BEFORE syntax-highlighting)
  zsh-syntax-highlighting  # must be loaded last
)
```

Order matters: `fzf-tab` must load after `fzf-zsh-plugin` so it wins the `Tab`
binding, and `zsh-syntax-highlighting` must be last. The `fzf-tab` preview
`zstyle` configuration goes after `source $ZSH/oh-my-zsh.sh`; see the
[fzf Tab completion setup](fzf_tab_completion.md).

If you already use additional Oh My Zsh plugins, keep them and only add the missing entries above. For an idempotent setup, avoid blindly replacing the whole block unless you explicitly want to standardize on this exact list.

### Make `fnm` available before Oh My Zsh loads plugins

Ensure this block exists above `source $ZSH/oh-my-zsh.sh`:

```zsh
# Make fnm available before Oh My Zsh loads plugins.
if [ -d "$HOME/.fnm" ]; then
  export PATH="$HOME/.fnm:$PATH"
elif [ -n "$XDG_DATA_HOME" ] && [ -d "$XDG_DATA_HOME/fnm" ]; then
  export PATH="$XDG_DATA_HOME/fnm:$PATH"
elif [ -d "$HOME/.local/share/fnm" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
fi
```

### Keep `~/.local/bin` on `PATH`

Ensure this line exists below `source $ZSH/oh-my-zsh.sh`:

```zsh
export PATH="$HOME/.local/bin:$PATH"
```

### Hide the `agnoster` context segment

The current setup suppresses the `user@host` context in the prompt:

```zsh
prompt_context(){}
```

### Initialize `fnm`

Ensure this block exists near the end of `~/.zshrc`:

```zsh
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
```

## 7. Keep `.bashrc` aligned during the transition

The current bash fallback keeps `~/.local/bin` on `PATH` and initializes `fnm`.
Make sure `~/.bashrc` contains these lines once:

```bash
export PATH="$HOME/.local/bin:$PATH"

if [ -d "$HOME/.fnm" ]; then
  export PATH="$HOME/.fnm:$PATH"
elif [ -n "$XDG_DATA_HOME" ] && [ -d "$XDG_DATA_HOME/fnm" ]; then
  export PATH="$XDG_DATA_HOME/fnm:$PATH"
elif [ -d "$HOME/.local/share/fnm" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
fi

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell bash)"
fi
```

If you still have custom aliases or functions in `~/.bashrc`, copy only the ones you still want. The current Zsh setup relies mostly on Oh My Zsh plugins instead of carrying over the default bash aliases.

## 8. Reload the shell

```bash
exec zsh
```

## Verification

```bash
echo "Shell: $SHELL"
zsh --version
grep '^ZSH_THEME=' ~/.zshrc
grep -n '^plugins=' ~/.zshrc
grep -n 'fnm env --use-on-cd --shell zsh' ~/.zshrc
grep -n 'prompt_context(){}' ~/.zshrc
command -v fnm && fnm --version
```
