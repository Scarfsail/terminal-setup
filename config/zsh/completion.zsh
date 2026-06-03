# Completion — shared zsh config (sourced from ~/.zshrc).
#
# Cached compinit: full security audit/rebuild at most once a day.
# Glob qualifiers don't expand inside [[ ]], so collect matches in an array
# (assignment context) where they do: $zcd(N.mh+24) = file, older than 24h.
autoload -Uz compinit
() {
  local zcd="$HOME/.zcompdump"
  local -a stale=( $zcd(N.mh+24) )
  if (( $#stale )) || [[ ! -s $zcd ]]; then
    compinit -d "$zcd"        # missing/empty/>24h → rebuild (runs compaudit)
    touch "$zcd"              # refresh mtime: compinit skips rewriting an
                              # unchanged dump, so without this the >24h check
                              # would re-run compaudit (~250ms) on every startup
  else
    compinit -C -d "$zcd"     # fresh → trust dump, skip the security audit
  fi
}

# Completion styling (previously inherited from Oh My Zsh).
zstyle ':completion:*' menu no
zstyle ':completion:*:*:*:*:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
_comp_options+=(globdots)     # include dotfiles in completion
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' special-dirs ..        # offer ../ but not ./
zstyle ':completion:*:(all-files|globbed-files)' ignored-patterns '..'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
