# Key bindings — shared zsh config (sourced from ~/.zshrc).

# Ctrl+Left / Ctrl+Right: jump by word (xterm sequences sent by WezTerm).
# Without these, ZLE inserts the literal ";5C"/";5D" tail of the escape sequence.
bindkey '^[[1;5C' forward-word    # Ctrl+Right
bindkey '^[[1;5D' backward-word   # Ctrl+Left
