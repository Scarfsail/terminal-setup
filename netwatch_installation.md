# netwatch Installation

Official pages:

- <https://github.com/matthart1983/netwatch>

`netwatch` is a Rust terminal-UI network monitor (the `netwatch-tui` crate). It captures and displays live network traffic in an interactive TUI. Packet capture requires elevated privileges (raw sockets), so it is typically run with `sudo`.

## Install via pre-built binary (recommended)

This is the method used on this machine. The **static** build bundles libpcap, so no `libpcap-dev` is needed at runtime, and installing into `/usr/local/bin` keeps it on `sudo`'s `secure_path`.

```bash
# x86_64 Linux, static build. Bump the version/arch to match the latest release.
VER=$(curl -fsSL https://api.github.com/repos/matthart1983/netwatch/releases/latest \
  | grep -oP '"tag_name": "\K[^"]+')
cd /tmp && rm -rf netwatch-install && mkdir netwatch-install && cd netwatch-install
curl -fsSL -o nw.tar.gz \
  "https://github.com/matthart1983/netwatch/releases/download/${VER}/netwatch-linux-x86_64-static.tar.gz"
tar -xzf nw.tar.gz
sudo install -m 755 netwatch-linux-x86_64-static /usr/local/bin/netwatch
cd / && rm -rf /tmp/netwatch-install
```

Available release assets: `netwatch-linux-{x86_64,aarch64}[-static].tar.gz`, `netwatch-macos-{x86_64,aarch64}.tar.gz`. Use `uname -m` to check architecture (`x86_64` here).

## Install via Homebrew

```bash
brew install matthart1983/tap/netwatch
```

> ⚠️ Homebrew installs to `/home/linuxbrew/.linuxbrew/bin`, which is **not** on `sudo`'s `secure_path` (`/bin:/usr/bin`). As a result `sudo netwatch` fails with "command not found" even though plain `netwatch` works. The pre-built-binary method above avoids this because `/usr/local/bin` is on `secure_path`. If you keep the brew install, either run `sudo /home/linuxbrew/.linuxbrew/bin/netwatch`, use `sudo env "PATH=$PATH" netwatch`, or add the brew bin to `secure_path` via `sudo visudo`.

If both the brew and `/usr/local/bin` copies are installed, plain `netwatch` resolves to whichever directory comes first in `PATH`. To keep only the binary copy: `brew uninstall netwatch`.

## Install via Cargo

```bash
sudo apt install -y libpcap-dev   # build + runtime dependency
cargo install netwatch-tui
```

> Installs to `~/.cargo/bin`, which has the same `sudo` PATH problem as Homebrew. For root access use `sudo cargo install netwatch-tui --root /usr/local`, or symlink the binary into `/usr/local/bin`.

## Build from source

```bash
sudo apt install -y libpcap-dev
git clone https://github.com/matthart1983/netwatch.git && cd netwatch
cargo build --release
sudo install -m 755 target/release/netwatch /usr/local/bin/netwatch
```

Requires Rust 1.70+ and `libpcap-dev`. License: MIT.

## Running without sudo (optional)

If `netwatch` only needs root for packet capture, grant the capability once instead of using `sudo` every time:

```bash
sudo setcap cap_net_raw,cap_net_admin+eip "$(command -v netwatch)"
```

> `setcap` is most reliable on a binary in `/usr/local/bin`. It can be flaky on Homebrew binaries under WSL/overlay filesystems.

## Verify

```bash
netwatch --version
sudo netwatch --version
```

Both should print the version (e.g. `netwatch 0.15.10`). If `sudo netwatch` fails, see the Homebrew note above.
