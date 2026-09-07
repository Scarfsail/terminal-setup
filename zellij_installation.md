# Zellij Installation

Official project: <https://github.com/zellij-org/zellij>

## Install or confirm

Ubuntu/Debian does not reliably provide a current `zellij` package, so use the upstream release binary.

```bash
arch="$(uname -m)"
case "$arch" in
  x86_64) target="x86_64-unknown-linux-musl" ;;
  aarch64|arm64) target="aarch64-unknown-linux-musl" ;;
  *) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
esac

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

tag="$(curl -fsSL https://api.github.com/repos/zellij-org/zellij/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)"
asset="zellij-${target}.tar.gz"
curl -fL "https://github.com/zellij-org/zellij/releases/download/${tag}/${asset}" -o "$tmpdir/$asset"
tar -xzf "$tmpdir/$asset" -C "$tmpdir"

install -d "$HOME/.local/bin"
install -m 0755 "$tmpdir/zellij" "$HOME/.local/bin/zellij"
```

If you prefer a system-wide install and have passwordless `sudo` configured, replace the last two lines with:

```bash
sudo install -m 0755 "$tmpdir/zellij" /usr/local/bin/zellij
```

## Minimal baseline

`zellij` works without any extra theme or plugin framework. Start with the default layout and add configuration only after the user has used it enough to know what they want to change.

This repository keeps the Zellij *install* intentionally small:

- install the upstream binary
- keep it reachable through `~/.local/bin`

## Config (repo-managed)

The reviewed machine has a customized config (custom keybinds with
`clear-defaults=true`). It is version-controlled here and **symlinked** into
place, so edits in either location apply:

```bash
mkdir -p ~/.config/zellij
[ -e ~/.config/zellij/config.kdl ] && [ ! -L ~/.config/zellij/config.kdl ] && \
  mv ~/.config/zellij/config.kdl ~/.config/zellij/config.kdl.bak
ln -sfn "$HOME/dev/terminal-setup/config/zellij/config.kdl" ~/.config/zellij/config.kdl
```

Source: [`config/zellij/config.kdl`](config/zellij/config.kdl). On a brand-new
machine where you'd rather start from defaults, skip the symlink and let Zellij
generate its own config (`zellij setup --dump-config`).

## Migrating from tmux

Some machines start terminals into tmux from an old "auto-screen" snippet in
`~/.bashrc` (it fires only on SSH logins):

```bash
if [ "$PS1" != "" -a "${STARTED_SCREEN:-x}" = x -a "${SSH_TTY:-x}" != x ]
then
  ...
  /usr/bin/tmux new -s 0 && exit 0
  /usr/bin/tmux attach -t 0 && exit 0
fi
```

There is usually no tmux config to port (no `~/.tmux.conf`), so the migration is
just three steps:

1. Point `~/.config/zellij/config.kdl` at the repo copy (see [Config](#config-repo-managed)
   above); back up any pre-existing real file first.
2. Delete the auto-screen snippet from `~/.bashrc` and append the auto-start line
   from the section below instead. Note the behavior change: the tmux snippet ran
   only on SSH logins, while the Zellij one runs for every interactive shell (it
   no-ops inside Zellij).
3. Leave the `tmux` package installed — it's harmless and other tooling may shell
   out to it. `sudo apt purge tmux` if you want it gone.

The cutover applies to **new** shells; an attached tmux session keeps running
until you exit it.

## Verify

```bash
zellij --version
```

## First launch

```bash
zellij
```

Detach from a session with `Ctrl+o` then `d`.

## Auto-start on new terminals

This is an **optional** quality-of-life step.

If an AI agent is following this guide, it should **ask the user first** whether they want Zellij auto-start added to their shell startup file before editing `.zshrc` or any other shell config.

If the user wants every new terminal to either create a Zellij session or offer the existing sessions newest-first, use the repo-managed helper script:

The helper script itself is plain `bash`, so it works from either shell; only
the interactive-shell guard differs.

On **zsh**:

```bash
chmod +x ~/dev/terminal-setup/scripts/zellij/zellij-auto-start
echo '[[ -o interactive ]] && ~/dev/terminal-setup/scripts/zellij/zellij-auto-start' >> ~/.zshrc
```

On **bash** (machines that haven't done the [zsh migration](bash_to_zsh_migration.md) yet):

```bash
chmod +x ~/dev/terminal-setup/scripts/zellij/zellij-auto-start
echo '[[ $- == *i* ]] && ~/dev/terminal-setup/scripts/zellij/zellij-auto-start' >> ~/.bashrc
```

Append it **after** the `PATH` export that adds `~/.local/bin`, otherwise the
script won't find the `zellij` binary.

Behavior:

- outside Zellij: if no sessions exist, start a new one
- outside Zellij: if sessions exist, show a table sorted by most recent use with columns for number, last used, session name, tab count, pane count, and working directory; each session gets a single-key shortcut, and pressing Enter attaches to the most recently used session
- outside Zellij: below the table, `c` creates a new session and `s` skips Zellij for that terminal, both without needing Enter
- inside Zellij: do nothing, so new panes and tabs do not try to attach again
