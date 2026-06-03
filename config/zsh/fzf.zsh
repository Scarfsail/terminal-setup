# fzf + fzf-tab — shared zsh config (sourced from ~/.zshrc).
#
# Source this BEFORE the fzf-tab plugin: the native integration must be eval'd
# first so fzf-tab can then take over the Tab binding. The fzf-tab zstyles below
# are read at completion time, so setting them before the plugin loads is fine.

# fzf native integration: Ctrl-T (files), Ctrl-R (history), Alt-C (cd), ** trigger.
eval "$(fzf --zsh)"

# Resolve this repo's root from the file's own location, so the eza preview
# script path works no matter where the repo was cloned.
#   ${0:A} = .../terminal-setup/config/zsh/fzf.zsh  ->  :h:h:h = repo root
# (no `local` — this file is sourced at top level, not inside a function)
_ts="${0:A:h:h:h}"

# ---- fzf-tab configuration ----
# Don't inherit FZF_DEFAULT_OPTS (it hides/overrides previews); set flags + colors.
zstyle ':fzf-tab:*' use-fzf-default-opts no
zstyle ':fzf-tab:*' fzf-flags --height=90% --layout=reverse --info=inline \
  --preview-window=right:60%:wrap \
  --color=hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008
# Tab inside the popup descends into the highlighted dir and keeps completing.
zstyle ':fzf-tab:*' continuous-trigger 'tab'
# cd / zoxide `z`: preview dir contents (icon+name left, dim size+date right).
zstyle ':fzf-tab:complete:cd:*' fzf-preview "$_ts/scripts/fzf/eza-fzf-preview \$realpath"
zstyle ':fzf-tab:complete:z:*'  fzf-preview "$_ts/scripts/fzf/eza-fzf-preview \$realpath"
# git: preview diffs / logs for the candidate ref.
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff --color=always -- $word | head -200'
zstyle ':fzf-tab:complete:git-checkout:*'           fzf-preview 'git log --oneline --color=always -20 $word'
# export / env vars: show the current value.
zstyle ':fzf-tab:complete:(export|unset|printenv):*' fzf-preview 'echo ${(P)word}'
# Catch-all (least specific): file contents via batcat, dirs via the eza script.
zstyle ':fzf-tab:complete:*:*' fzf-preview "
  if [[ -d \$realpath ]]; then
    $_ts/scripts/fzf/eza-fzf-preview \$realpath
  elif [[ -f \$realpath ]]; then
    batcat --color=always --style=numbers --line-range=:300 \$realpath 2>/dev/null
  fi"

unset _ts
