# Snap PATH Setup

Official pages:

- <https://snapcraft.io/docs/installing-snapd>

On Ubuntu/Debian, snap installs binaries into `/snap/bin`. Login shells normally pick this up via `/etc/profile.d/apparmor.sh` or `/etc/environment`, but several environments do **not**:

- non-login interactive shells started by VS Code's `vscode-server` / WSL integration
- shells launched by editors and IDEs that bypass `/etc/profile`
- some `tmux` and multiplexer setups that inherit a stripped `PATH`

The symptom is that `snap list <name>` shows the package as installed, but running the command prints `command not found`.

## Add `/snap/bin` to zsh PATH

Append the following to `~/.zshrc` (idempotent — adds the entry only if `/snap/bin` exists and is not already on `PATH`):

```bash
# Snap binaries — non-login shells (vscode-server, some tmux setups) don't pick this up.
[ -d /snap/bin ] && case ":$PATH:" in
  *":/snap/bin:"*) ;;
  *) export PATH="$PATH:/snap/bin" ;;
esac
```

Reload the current shell:

```bash
source ~/.zshrc
```

## Verify

```bash
echo "$PATH" | tr ':' '\n' | grep -x /snap/bin
```

The command should print `/snap/bin`. After this, any snap-installed CLI (for example `glow`) is resolvable by name.
