# eza (modern `ls` replacement) — shared zsh config (sourced from ~/.zshrc).
#
# Guarded by `command -v eza` so the file is harmless on machines where eza
# isn't installed yet (the plain `ls`/`tree` builtins keep working). See the
# install + flag reference in eza_installation.md.

if command -v eza >/dev/null 2>&1; then
  export EZA_ICONS_AUTO=1                       # icons when output is a terminal (needs a Nerd Font)
  eza_opts=(--group-directories-first --git)
  alias ls="eza $eza_opts"
  alias l="eza $eza_opts -lbF"                  # long, binary sizes, type indicators
  alias ll="eza $eza_opts -lbhHigUmuSa --time-style=long-iso"  # all details
  alias la="eza $eza_opts -lbhHigUmuSa"
  alias lt="eza $eza_opts --tree --level=2"     # tree, 2 levels
  alias tree="eza $eza_opts --tree"
  unset eza_opts
fi
