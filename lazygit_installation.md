# lazygit Installation

Official pages:

- <https://lazygit.dev/download/>
- <https://github.com/jesseduffield/lazygit>

For Ubuntu/Debian on WSL, the official site recommends `go install` on Linux. If you do not want Go just to install lazygit, the release tarball flow is a good fit and matches the binary-release style already present on the reviewed machine.

## Option A: install from the official release tarball

```bash
if command -v lazygit >/dev/null 2>&1; then
  echo "lazygit already installed: $(lazygit --version | head -n 1)"
else
  LAZYGIT_VERSION="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[^"]*')"
  curl -Lo lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm -f lazygit lazygit.tar.gz
fi
```

For ARM64, replace `Linux_x86_64` with `Linux_arm64`.

## Option B: follow the official Linux recommendation with Go

```bash
command -v lazygit >/dev/null 2>&1 || go install github.com/jesseduffield/lazygit@latest
```

If you use this route, make sure your Go bin directory is on `PATH`.

## Minimal baseline

No extra config is required. Start it inside any Git repository:

```bash
cd /path/to/repo
lazygit
```

## Config (repo-managed)

The reviewed machine uses [`delta`](https://github.com/dandavison/delta) as
lazygit's diff pager. That config is version-controlled here and **symlinked**
into place:

```bash
mkdir -p ~/.config/lazygit
[ -e ~/.config/lazygit/config.yml ] && [ ! -L ~/.config/lazygit/config.yml ] && \
  mv ~/.config/lazygit/config.yml ~/.config/lazygit/config.yml.bak
ln -sfn "$HOME/dev/terminal-setup/config/lazygit/config.yml" ~/.config/lazygit/config.yml
```

Source: [`config/lazygit/config.yml`](config/lazygit/config.yml). It requires
`delta` on `PATH` — install it (e.g. `sudo apt install git-delta`, or the upstream
release binary if the package is unavailable). Without `delta`, drop the symlink
to fall back to lazygit's built-in pager.

## Verify

```bash
lazygit --version
command -v delta && readlink ~/.config/lazygit/config.yml
```
