# falcode-zellij Installation (Claude Code + Codex)

Official project: <https://github.com/victor-falcon/falcode-zellij>

A Zellij plugin that lists every active AI agent pane across all your Zellij
sessions in a floating popup, so you can jump straight to the one that needs
you. Upstream supports OpenCode, pi, oh-my-pi and Claude Code. **Codex support
is not upstream** — this repo adds it (see [Codex](#4-codex-support)).

Two pieces make it work:

- the **WASM plugin**, which draws the popup, and
- a **reporter** per agent, which writes that pane's status into a shared state
  directory. The popup reads it through an editable detection script.

Status values are `working`, `waiting_user_input`, `asking_permissions` and
`waiting_user_answers`.

> **macOS only:** the click-to-focus notification helper (`oc-notify.sh`) drives
> `osascript` and `terminal-notifier`. Skip it on Linux and WSL. Jumping between
> panes, which is the point of the plugin, does not need it.

## 1. Install the plugin

```bash
mkdir -p ~/.config/zellij/plugins ~/.local/state/falcode-zellij
curl -fsSL https://github.com/victor-falcon/falcode-zellij/releases/latest/download/falcode-zellij-sessions.wasm \
  -o ~/.config/zellij/plugins/falcode-zellij-sessions.wasm
```

No Rust toolchain is needed; the release ships a prebuilt binary.

## 2. Install the shared scripts

The detection script is normally installed by the OpenCode plugin or the pi
extension. With only Claude Code and Codex reporting, fetch it yourself:

```bash
base=https://raw.githubusercontent.com/victor-falcon/falcode-zellij/main
curl -fsSL "$base/claude-extension/falcode-hook.sh" \
  -o ~/.local/state/falcode-zellij/falcode-hook.sh
curl -fsSL "$base/scripts/detect-active-opencode.sh" \
  -o ~/.local/state/falcode-zellij/detect-active-opencode.sh
cp ~/.local/state/falcode-zellij/detect-active-opencode.sh \
   ~/.local/state/falcode-zellij/detect-active-opencode.default.sh
chmod +x ~/.local/state/falcode-zellij/*.sh
```

`detect-active-opencode.sh` is meant to be edited locally and is never
overwritten by an upgrade; `detect-active-opencode.default.sh` is the reference
copy that does get refreshed. The Codex patch in
[section 4](#4-codex-support) relies on that.

## 3. Claude Code

Claude Code reports through hooks. Merge this into the `hooks` block of
`~/.claude/settings.json`, keeping any hooks you already have. Claude does not
expand `~` inside hook commands, so the home directory is spelled out.

```json
  "hooks": {
    "SessionStart":     [{ "hooks": [{ "type": "command", "command": "/home/ondra/.local/state/falcode-zellij/falcode-hook.sh SessionStart" }] }],
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "/home/ondra/.local/state/falcode-zellij/falcode-hook.sh UserPromptSubmit" }] }],
    "PreToolUse":       [{ "hooks": [{ "type": "command", "command": "/home/ondra/.local/state/falcode-zellij/falcode-hook.sh PreToolUse" }] }],
    "PostToolUse":      [{ "hooks": [{ "type": "command", "command": "/home/ondra/.local/state/falcode-zellij/falcode-hook.sh PostToolUse" }] }],
    "Notification":     [{ "hooks": [{ "type": "command", "command": "/home/ondra/.local/state/falcode-zellij/falcode-hook.sh Notification" }] }],
    "Stop":             [{ "hooks": [{ "type": "command", "command": "/home/ondra/.local/state/falcode-zellij/falcode-hook.sh Stop" }] }],
    "SessionEnd":       [{ "hooks": [{ "type": "command", "command": "/home/ondra/.local/state/falcode-zellij/falcode-hook.sh SessionEnd" }] }]
  },
```

If a `PreToolUse` hook is already present, append the falcode entry as a second
element of that array rather than replacing it. Restart Claude Code afterwards.

## 4. Codex support

Not provided upstream. This repo ships an equivalent reporter,
[`scripts/falcode-zellij/falcode-codex-hook.sh`](scripts/falcode-zellij/falcode-codex-hook.sh),
which writes the same pane state JSON with `"agent": "codex"`.

Codex CLI 0.150 and later has a hook system closely modelled on Claude's.
Requires `codex --version` at 0.150 or newer.

### 4a. Symlink the reporter

```bash
ln -sfn "$PWD/scripts/falcode-zellij/falcode-codex-hook.sh" \
  ~/.local/state/falcode-zellij/falcode-codex-hook.sh
```

### 4b. Teach the detection script about Codex

The bundled detection script only recognises four agents, so a Codex pane is
dropped before it reaches the popup. Three edits to
`~/.local/state/falcode-zellij/detect-active-opencode.sh` fix that. In
`agent_name()`, add the label:

```awk
    return agent == "claude" ? "Claude" : agent == "codex" ? "Codex" : agent == "pi" ? "Pi" : agent == "omp" ? "OMP" : "OpenCode"
```

In `is_supported_agent()`, accept the agent:

```awk
    return agent == "opencode" || agent == "claude" || agent == "codex" || agent == "pi" || agent == "omp"
```

In `is_agent_pane()`, add `program == "codex"` and
`index(lower_command, "codex")` to the returned expression. That last one only
affects untracked panes in the current session, which the popup lists on a
best-effort basis by command name.

### 4c. Register the hooks

Append to `~/.codex/config.toml`, once per event:

```toml
# falcode-zellij: report Codex pane status to the Zellij agent popup.
[[hooks.SessionStart]]
[[hooks.SessionStart.hooks]]
type = "command"
command = "/home/ondra/.local/state/falcode-zellij/falcode-codex-hook.sh SessionStart"
timeout = 5
```

Repeat for `UserPromptSubmit`, `PreToolUse`, `PostToolUse`,
`PermissionRequest`, `Stop`, `Interrupt` and `SessionEnd`, passing each event
name as the argument.

**Use `timeout = 3` for `SessionEnd` and `Interrupt`.** Codex caps those two at
3 seconds and prints a `clamping ... hook timeout` warning on every start
otherwise.

Codex requires explicit trust for hooks it did not install itself. On the next
start, approve them with `/hooks`. Trust is recorded per hook hash in a
`[hooks.state]` table written into `config.toml`, so editing a hook definition
asks for that one to be trusted again.

### How Codex events map to statuses

| Event | Status |
|---|---|
| `SessionStart`, `Stop`, `Interrupt` | `waiting_user_input` |
| `UserPromptSubmit`, `PreToolUse`, `PostToolUse` | `working` |
| `PermissionRequest` | `asking_permissions` |
| `SessionEnd` | state file deleted, pane leaves the popup |

Two behaviours differ from the Claude reporter, both because Codex exposes less:

- **No question status.** Codex has no elicitation event, so
  `waiting_user_answers` is never produced. Only permission prompts raise
  attention.
- **No idle suppression.** The Claude hook inspects `background_tasks` and
  `session_crons` in the `Stop` payload to avoid calling a paused session
  finished. Codex publishes no equivalent, so a Codex session parked mid-task
  reads as idle.

## 5. Bind the popup

The plugin config value is not shell-expanded, so `~` and `$HOME` do not work
here either. Add to [`config/zellij/config.kdl`](config/zellij/config.kdl),
inside a `shared_except "locked"` block:

```kdl
        bind "Alt a" {
            LaunchOrFocusPlugin "file:/home/ondra/.config/zellij/plugins/falcode-zellij-sessions.wasm" {
                floating true
                state_dir "/home/ondra/.local/state/falcode-zellij"
            }
        }
```

`Alt+a` is used because `Alt+o`, the upstream suggestion, is already bound to
`MoveTab` in this repo's Zellij config. `state_dir` must match where the
reporters write.

## Verify

Reporters only act inside Zellij: they read `ZELLIJ_PANE_ID` and
`ZELLIJ_SESSION_NAME`, and exit silently when either is missing. Start an agent
in a Zellij pane, then check that a state file appeared:

```bash
ls ~/.local/state/falcode-zellij/panes/
FALCODE_STATE_DIR=$HOME/.local/state/falcode-zellij \
  ~/.local/state/falcode-zellij/detect-active-opencode.sh
```

The script prints one JSON object per live agent pane. Press `Alt+a` to open the
popup.

## Troubleshooting

- **Popup is empty.** Pane state older than 180 seconds is discarded, and panes
  missing from Zellij's live pane list are filtered out. Send a prompt to the
  agent and look again.
- **A pane never appears.** Confirm the hooks are registered and, for Codex,
  trusted. Set `FALCODE_CLAUDE_HOOK_DEBUG=1` or `FALCODE_CODEX_HOOK_DEBUG=1` to
  log raw payloads to `claude-hook.log` or `codex-hook.log` in the state
  directory.
- **A pane is stuck on `working`.** The agent exited without its stop or session
  end event firing. The 180 second age cut-off clears it.
