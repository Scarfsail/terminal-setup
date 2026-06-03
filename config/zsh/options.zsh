# Shell options — shared zsh config (sourced from ~/.zshrc).
setopt auto_cd                # `foo` == `cd foo` when foo is a dir
setopt auto_pushd             # cd pushes onto the dir stack
setopt pushd_ignore_dups
setopt interactive_comments   # allow `# comments` in the interactive shell
setopt prompt_subst
