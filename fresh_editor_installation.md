# Fresh Editor Installation

Official pages:

- <https://getfresh.dev/>
- <https://github.com/sinelaw/fresh>

Fresh's upstream README advertises the install script as the quick-install path, and that is the best fit for this setup.

## Install with the official script

```bash
if command -v fresh >/dev/null 2>&1; then
  echo "fresh already installed: $(fresh --version)"
else
  curl https://raw.githubusercontent.com/sinelaw/fresh/refs/heads/master/scripts/install.sh | sh
fi
```

## Minimal baseline

Fresh is designed to work with zero configuration. The main requirement for this setup is that `~/.local/bin` stays on `PATH`, because that is where user-level tools commonly land.

The current shell docs in this repository already keep `~/.local/bin` on `PATH`.

## Launch

```bash
fresh
```

Open a file directly:

```bash
fresh path/to/file
```

## Set as default `$EDITOR`

Many CLIs (`git commit`, `glow`, `crontab -e`, etc.) launch whatever is in `$VISUAL` or `$EDITOR`. Point both at `fresh` so they all open it. `fresh` installs to `/usr/bin/fresh`, which is on the default `PATH` for interactive shells, GUI launches, and cron, so the bare command name is enough — no absolute path needed.

Add to `~/.zshrc` (replacing the commented-out Oh My Zsh template block if present):

```sh
export EDITOR=fresh
export VISUAL=fresh
```

Reload with `source ~/.zshrc` or open a new shell.

## Verify

```bash
fresh --version
command -v fresh
echo "$EDITOR / $VISUAL"
```
