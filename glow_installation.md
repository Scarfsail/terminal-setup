# glow Installation

Official pages:

- <https://github.com/charmbracelet/glow>
- <https://snapcraft.io/glow>

`glow` is a terminal Markdown renderer from Charmbracelet. The Charmbracelet apt repository is the upstream-recommended route on Debian/Ubuntu; the snap package is a single-command alternative that does not require adding a third-party apt source.

## Option A: install via snap

```bash
if command -v glow >/dev/null 2>&1; then
  echo "glow already installed: $(glow --version)"
else
  sudo snap install glow
fi
```

If `glow` is reported as installed by `snap list glow` but `command -v glow` still fails, `/snap/bin` is missing from your `PATH`. Follow [Snap PATH setup](snap_path_setup.md) to fix this once for all snap-installed CLIs.

## Option B: install from the Charmbracelet apt repository

```bash
if command -v glow >/dev/null 2>&1; then
  echo "glow already installed: $(glow --version)"
else
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://repo.charm.sh/apt/gpg.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
    | sudo tee /etc/apt/sources.list.d/charm.list
  sudo apt update
  sudo apt install -y glow
fi
```

## Minimal baseline

No extra config is required. Render a Markdown file:

```bash
glow README.md
```

Or page through it interactively:

```bash
glow -p README.md
```

## Default editor

On first run, `glow` warns that `$EDITOR` is unset. Configure it once via [Fresh editor installation → Set as default `$EDITOR`](fresh_editor_installation.md#set-as-default-editor) (or substitute any other editor) and the warning goes away.

## Verify

```bash
glow --version
```
