# fzf Tab Completion Setup (fzf-tab + eza)

This guide makes **Tab** completion run through [fzf](https://github.com/junegunn/fzf):
pressing `Tab` opens a fuzzy picker with a preview pane instead of zsh's plain
completion menu. It reflects the current default setup:

- [`fzf-tab`](https://github.com/Aloxaf/fzf-tab) takes over `Tab` and renders
  completions in fzf with previews.
- [`zsh-autosuggestions`](https://github.com/zsh-users/zsh-autosuggestions) shows
  greyed-out inline suggestions from history as you type.
- [`eza`](https://github.com/eza-community/eza) provides the directory preview
  used by `fzf-tab` (a modern `ls` replacement).
- The existing `fzf-zsh-plugin` keeps `Ctrl-T` / `Ctrl-R` / `Alt-C` working.

> **Important compatibility note:** `fzf-tab` and `marlonrichert/zsh-autocomplete`
> both take over the `Tab` key and **cannot coexist**. This setup does **not
> load** `zsh-autocomplete` (it is absent from the `plugins=(...)` list). The
> plugin directory may stay installed on disk — Oh My Zsh only loads plugins
> named in the array — so removing it is optional. If you prefer the live,
> as-you-type drop-down menu of `zsh-autocomplete`, do **not** load `fzf-tab`
> instead — pick one paradigm.

The commands below are written to be safe to re-run.

## 1. Install `eza`

`eza` is in the Ubuntu 26.04+ repositories:

```bash
if ! command -v eza >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y eza
fi
eza --version
```

> On older releases without an `eza` package, install from the upstream
> instructions at <https://github.com/eza-community/eza/blob/main/INSTALL.md>.
> If `eza` is unavailable, replace `eza ...` in the preview `zstyle` lines below
> with `ls -1 --color=always $realpath`.

## 2. Install the plugins

```bash
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

# fzf-powered Tab completion
if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
  git clone --depth 1 https://github.com/Aloxaf/fzf-tab \
    "$ZSH_CUSTOM/plugins/fzf-tab"
fi

# fzf binary glue (Ctrl-T / Ctrl-R / Alt-C / ** trigger)
if [ ! -d "$ZSH_CUSTOM/plugins/fzf-zsh-plugin" ]; then
  git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git \
    "$ZSH_CUSTOM/plugins/fzf-zsh-plugin"
fi

# Inline history suggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Syntax highlighting (must load last)
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
```

If you previously used `zsh-autocomplete`, just make sure it is **not** in your
`plugins=(...)` list (step 3) so it stops fighting `fzf-tab` over the `Tab` key.
Leaving the directory on disk is harmless since Oh My Zsh only loads plugins
named in the array; remove it entirely only if you want to:

```bash
# optional
rm -rf "$ZSH_CUSTOM/plugins/zsh-autocomplete"
```

## 3. Set the plugin list in `~/.zshrc`

Order matters: `fzf-tab` must load **after** `fzf-zsh-plugin` (so it wins the
`Tab` binding) and **before** `zsh-syntax-highlighting` (which must be last).

```zsh
plugins=(
  git
  zsh-autosuggestions      # greyed-out inline suggestions from history
  fzf-zsh-plugin           # fzf binary glue: Ctrl-T / Ctrl-R / Alt-C / ** trigger
  fzf-tab                  # fzf-powered Tab completion (load AFTER fzf, BEFORE syntax-highlighting)
  zsh-syntax-highlighting  # must be loaded last
)
```

## 4. Add the `fzf-tab` configuration

Place this block **after** `source $ZSH/oh-my-zsh.sh` in `~/.zshrc`:

```zsh
# ---- fzf-tab configuration ----
# Disable zsh's default menu selector so fzf-tab can take over Tab.
# (the 5-colon override neutralizes Oh My Zsh's own `menu select` default)
zstyle ':completion:*' menu no
zstyle ':completion:*:*:*:*:*' menu no
# Case-insensitive / partial-word matching (was previously provided by zsh-autocomplete).
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# Include hidden (dot) entries in completion, so `cd`/`z <Tab>` show .config,
# .git, etc. (completion-scoped: does not change normal shell globbing). This
# also reduces fzf-tab's single-child auto-skip, since dotfolders now count.
_comp_options+=(globdots)
# List directories before files in file completion (e.g. `cat <Tab>` /
# `vim <Tab>` show folders first, then files — each sorted by name). fzf-tab
# renders these as ordered groups (directories group on top).
zstyle ':completion:*' list-dirs-first true
# Don't inherit FZF_DEFAULT_OPTS: it sets `--preview-window=:hidden` and its own
# `--preview`, which would hide/override fzf-tab's previews. Use explicit flags
# with a visible preview pane and the same color scheme instead.
zstyle ':fzf-tab:*' use-fzf-default-opts no
zstyle ':fzf-tab:*' fzf-flags --height=90% --layout=reverse --info=inline \
  --preview-window=right:60%:wrap \
  --color=hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008
# Press Tab inside the popup to descend into the highlighted dir and keep
# completing (Tab opens completion *and* drills deeper). '/' stays a normal
# query character.
zstyle ':fzf-tab:*' continuous-trigger 'tab'
# cd / dirs: preview contents — icon+name left, dim size+date right-aligned
# (see "Directory preview script" below). zoxide `z <Tab>` (no keyword)
# completes local dirs via `_cd`, so it uses the same preview.
# (The completion context key is `z`, not `__zoxide_z`.)
zstyle ':fzf-tab:complete:cd:*' fzf-preview '$HOME/dev/terminal-setup/scripts/fzf/eza-fzf-preview $realpath'
zstyle ':fzf-tab:complete:z:*'  fzf-preview '$HOME/dev/terminal-setup/scripts/fzf/eza-fzf-preview $realpath'
# git: preview diffs / logs for the candidate ref.
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff --color=always -- $word | head -200'
zstyle ':fzf-tab:complete:git-checkout:*'           fzf-preview 'git log --oneline --color=always -20 $word'
# export / env vars: show the current value.
zstyle ':fzf-tab:complete:(export|unset|printenv):*' fzf-preview 'echo ${(P)word}'
```

### Directory preview script

The `cd`/`z` previews call [`scripts/fzf/eza-fzf-preview`](scripts/fzf/eza-fzf-preview),
which renders the directory with the **icon + name on the left (dominant)** and a
**dimmed `size  modified-date` right-aligned** on each line. Hidden entries are
included. It right-aligns to fzf's `$FZF_PREVIEW_COLUMNS` so the columns always
fit the pane. `eza` can't put metadata to the right of the name itself, and
fzf-tab runs previews via a non-interactive `zsh -c`, so the logic must live in a
standalone executable (a `.zshrc` function would not be visible) — hence the script.

It has two styles (default **flat**): flip the `style` variable at the top of the
script, or `export EZA_PREVIEW_STYLE=tree`, to switch:

- `flat` — one level, plain listing (dirs first). **Default.**
- `tree` — a 2-level tree with branch art (`.git`/`node_modules` pruned).

Make sure it is executable, and adjust the path in the two `fzf-preview`
zstyles above if you cloned this repo somewhere other than `~/dev/terminal-setup`:

```bash
chmod +x ~/dev/terminal-setup/scripts/fzf/eza-fzf-preview
```

Notes:

- It needs `eza` (above) and a **Nerd Font** for the icon glyphs. `eza` only
  emits icons/colors to a pipe with `--icons=always` / `--color=always` (plain
  `--icons` silently shows nothing when piped, as fzf previews are).
- To restyle, edit the script — switch `style` (flat/tree), change `depth` (tree
  levels) or `ignore` (pruned globs), add git status (`--git`), or change the
  date format (`--time-style`).

## 5. Reload the shell

```bash
exec zsh
```

## What you get

| Action | Result |
|---|---|
| `cd <Tab>` | fzf picker of directories; preview shows icon+name left, dim size+date right (flat; tree optional) |
| `z <Tab>` | zoxide: completes local dirs via `_cd`, with the same directory preview |
| `git checkout <Tab>` | branches in fzf, preview shows that ref's log |
| `git add <Tab>` / `git diff <Tab>` | paths in fzf, preview shows the diff |
| `export <Tab>` | env vars in fzf, preview shows each value |
| `vim src/<Tab>` | files in fzf with a `bat` preview |
| `Tab` while in a fzf-tab popup | descend into the highlighted dir and keep completing |
| `Ctrl-T` / `Ctrl-R` / `Alt-C` | unchanged (file insert / history / cd into subdir) |
| typing a command | greyed-out autosuggestion from history (`→` to accept) |

> Because `fzf-tab` owns `Tab`, fzf's `**<Tab>` trigger is superseded. Plain
> `<Tab>` and `Ctrl-T` cover those cases. Rebind the trigger via
> `FZF_COMPLETION_TRIGGER` if you want it back on a different sequence.

> The `z` preview only applies to plain `z <Tab>` (local-directory completion).
> Typing `z <keyword><Tab>` switches zoxide into its own *interactive query*
> mode, which jumps straight to the best database match and is not a normal
> completion list — so no fzf-tab preview is shown there, by design.

> Descending with `Tab` auto-skips **unambiguous single-child** directory
> chains: if a folder has exactly one matching subdirectory, fzf-tab fills it
> and keeps going (mirroring normal zsh Tab completion), so a single `Tab` can
> land several levels deep and then exit. `globdots` (above) reduces this by
> letting dotfolders count as siblings. fzf-tab has no option to force the
> popup to stop on a single match without patching the plugin.

## Verification

```bash
grep -n '^plugins=' ~/.zshrc
command -v eza && eza --version
# Tab should be bound to fzf-tab-complete:
zsh -ic 'bindkey "^I"'
# fzf-tab and autosuggestions should be loaded:
zsh -ic '(( $+functions[fzf-tab-complete] )) && echo "fzf-tab: ok"'
zsh -ic '(( $+functions[_zsh_autosuggest_start] )) && echo "autosuggest: ok"'
```
