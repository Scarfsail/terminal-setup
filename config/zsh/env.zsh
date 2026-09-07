# Environment — shared zsh config (sourced from ~/.zshrc).
export EDITOR=fresh
export VISUAL=fresh

# Use bat as the global pager (git, man-less, mc F3, etc.)
export PAGER='batcat --paging=always'

# Open browser-based auth flows in Windows from WSL.
# The wrapper at ~/.local/bin/xdg-open (scripts/wsl/xdg-open) uses PowerShell
# Start-Process, honoring the Windows default browser; explorer.exe would open
# File Explorer on URLs. Only set this under WSL — on a native Linux box that
# wrapper does not exist, and pointing BROWSER at a missing path breaks every
# tool that honors it. There, leave BROWSER to the desktop's own xdg-open.
if [[ -n ${WSL_DISTRO_NAME:-} ]] || grep -qi microsoft /proc/version 2>/dev/null; then
  export BROWSER="$HOME/.local/bin/xdg-open"
fi

# Convenience wrapper so `BROWSER <url>` works as an interactive command
# (shell functions aren't inherited by children — those use $BROWSER above).
# Defined only when some xdg-open is actually resolvable, so it is a no-op on a
# headless machine with no desktop integration.
if command -v xdg-open >/dev/null 2>&1; then
  BROWSER() { command xdg-open "$@"; }
fi
