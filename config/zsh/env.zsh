# Environment — shared zsh config (sourced from ~/.zshrc).
export EDITOR=fresh
export VISUAL=fresh

# Use bat as the global pager (git, man-less, mc F3, etc.)
export PAGER='batcat --paging=always'

# Open browser-based auth flows in Windows from WSL.
# xdg-open (in ~/.local/bin) uses PowerShell Start-Process, honoring the
# Windows default browser. explorer.exe would open File Explorer on URLs.
export BROWSER="$HOME/.local/bin/xdg-open"
# Convenience wrapper so `BROWSER <url>` works as an interactive command
# (shell functions aren't inherited by children — those use $BROWSER above).
BROWSER() { command xdg-open "$@"; }
