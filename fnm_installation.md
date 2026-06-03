# fnm Installation

Official project: <https://github.com/Schniz/fnm>

This setup uses `fnm` instead of `nvm`.

## Prerequisites

```bash
sudo apt update
sudo apt install -y curl unzip
```

## Install without auto-editing shell files

```bash
if command -v fnm >/dev/null 2>&1; then
  echo "fnm already installed: $(fnm --version)"
else
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi
```

The installer defaults to an XDG-style location on Linux, commonly `~/.local/share/fnm`. Some setups still use `~/.fnm`, so the shell snippets below handle both.

## Bash setup

Add this to `~/.bashrc` if the matching lines are not already present:

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

## Zsh setup

The shell is [framework-free](bash_to_zsh_migration.md) (no Oh My Zsh), so fnm is
wired in with two plain lines in `~/.zshrc` — put fnm's dir on `PATH`, then
evaluate its env:

```zsh
export PATH="$HOME/.local/share/fnm:$PATH"   # installer's default Linux location
eval "$(fnm env --use-on-cd --shell zsh)"
```

> Older installs used `~/.fnm`. If that's where yours lives, point the `PATH`
> line there instead (`export PATH="$HOME/.fnm:$PATH"`).

## Minimal baseline

Install an LTS Node.js release after `fnm` is ready:

```bash
fnm install --lts
fnm default lts-latest
```

## Verify

```bash
fnm --version
fnm current
node --version
```
