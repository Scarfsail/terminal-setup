# History — shared zsh config (sourced from ~/.zshrc).
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history       # record timestamp of each command
setopt hist_expire_dups_first # trim duplicates first when HISTFILE is full
setopt hist_ignore_dups       # don't record an entry that's a dup of the previous
setopt hist_ignore_space      # don't record entries starting with a space
setopt hist_verify            # don't execute a !history expansion immediately
setopt inc_append_history     # write to HISTFILE as commands are entered
setopt share_history          # share history across concurrent sessions
