#!/usr/bin/env bash
#
# Codex CLI hook for Falcode-Zellij session status reporting.
#
# Modelled on claude-extension/falcode-hook.sh from victor-falcon/falcode-zellij,
# which upstream does not ship a Codex reporter for. Writes the same pane state
# JSON into $STATE_DIR/panes/ so the popup lists Codex panes next to Claude ones.
#
# Codex passes the hook a single JSON object on stdin and the event name is
# taken from argv (hook_event_name in the payload is the same value).
#
# Always exits 0 so a misbehaving hook never blocks Codex.

set -uo pipefail

EVENT="${1:-}"
[[ -z $EVENT ]] && exit 0

PANE_ID="${ZELLIJ_PANE_ID:-}"
SESSION_NAME="${ZELLIJ_SESSION_NAME:-}"
# Outside zellij: nothing to track.
[[ -z $PANE_ID || -z $SESSION_NAME ]] && exit 0

STATE_ROOT="${FALCODE_STATE_DIR:-${HOME:-.}/.local/state/falcode-zellij}"
PANES_DIR="$STATE_ROOT/panes"
mkdir -p "$PANES_DIR" 2>/dev/null || exit 0

SAFE_SESSION="${SESSION_NAME//[^a-zA-Z0-9_-]/_}"
STATE_FILE="$PANES_DIR/${SAFE_SESSION}_${PANE_ID}.json"
NOTIFY_SCRIPT="${FALCODE_NOTIFY_SCRIPT:-$STATE_ROOT/oc-notify.sh}"

# Drain stdin JSON if present so Codex doesn't see a broken pipe.
STDIN_JSON=""
if [[ ! -t 0 ]]; then
  STDIN_JSON="$(cat 2>/dev/null || true)"
fi

# Opt-in debug log of raw hook payloads (set FALCODE_CODEX_HOOK_DEBUG=1).
if [[ ${FALCODE_CODEX_HOOK_DEBUG:-0} == "1" ]]; then
  DEBUG_LOG="$STATE_ROOT/codex-hook.log"
  if [[ -f $DEBUG_LOG ]] && [[ $(wc -c <"$DEBUG_LOG" 2>/dev/null || echo 0) -gt 262144 ]]; then
    rm -f "$DEBUG_LOG"
  fi
  {
    printf -- '--- %s event=%s session=%s pane=%s\n' \
      "$(date -u +%FT%TZ)" "$EVENT" "$SESSION_NAME" "$PANE_ID"
    printf '%s\n' "$STDIN_JSON"
  } >>"$DEBUG_LOG" 2>/dev/null || true
fi

# Extract a top-level string field from the JSON payload.
hook_field() {
  python3 -c '
import json, sys
key = sys.argv[1]
try:
    data = json.loads(sys.stdin.read())
except Exception:
    sys.exit(0)
val = data.get(key)
if isinstance(val, str):
    print(val)
' "$1" 2>/dev/null
}

# SessionEnd: drop the state file so the popup stops listing this pane.
if [[ $EVENT == "SessionEnd" ]]; then
  rm -f "$STATE_FILE"
  exit 0
fi

case "$EVENT" in
  SessionStart)
    STATUS="waiting_user_input"
    ;;
  UserPromptSubmit|PreToolUse|PostToolUse)
    STATUS="working"
    ;;
  PermissionRequest)
    # Fires just before Codex shows the approval prompt. Codex has no separate
    # elicitation event, so waiting_user_answers is never produced here.
    STATUS="asking_permissions"
    ;;
  Stop|Interrupt)
    # Stop fires when the turn completes and control returns to the user;
    # Interrupt when the user cancels one. Both mean "your turn".
    STATUS="waiting_user_input"
    ;;
  *)
    exit 0
    ;;
esac

# Read prev status from existing state file (only if it belongs to codex;
# a stale file from another agent must not trigger a fake transition).
PREV_STATUS="waiting_user_input"
HAD_PREV=0
if [[ -f $STATE_FILE ]]; then
  prev_agent="$(sed -n 's/.*"agent"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$STATE_FILE" | head -n 1)"
  if [[ $prev_agent == "codex" ]]; then
    HAD_PREV=1
    prev_status_value="$(sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$STATE_FILE" | head -n 1)"
    [[ -n $prev_status_value ]] && PREV_STATUS="$prev_status_value"
  fi
fi

NOW_MS="$(python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null || echo "$(($(date +%s) * 1000))")"
# Prefer the payload cwd: the hook process inherits Codex's working directory,
# but the payload is the authoritative per-session value.
CWD=""
[[ -n $STDIN_JSON ]] && CWD="$(hook_field cwd <<<"$STDIN_JSON")"
[[ -z $CWD ]] && CWD="${PWD:-}"
STABLE_ID="${SESSION_NAME}:${PANE_ID}"

python3 - "$STATE_FILE" "$STABLE_ID" "$PANE_ID" "$SESSION_NAME" "$STATUS" "$CWD" "$NOW_MS" <<'PY' 2>/dev/null || true
import json
import sys

state_file, stable_id, pane_id, session_name, status, cwd, updated_at_ms = sys.argv[1:8]
payload = {
    "agent": "codex",
    "cwd": cwd,
    "stable_id": stable_id,
    "pane_id": int(pane_id),
    "session_name": session_name,
    "status": status,
    "updated_at_ms": int(updated_at_ms),
}
with open(state_file, "w", encoding="utf-8") as fh:
    json.dump(payload, fh, indent=2)
    fh.write("\n")
PY

# First write (no prior codex state) and no-op transitions are silent.
if [[ $HAD_PREV -eq 0 || $STATUS == "$PREV_STATUS" ]]; then
  exit 0
fi

# zellij-attention pipe: same contract as the Claude hook.
if [[ ${FALCODE_DISABLE_ATTENTION:-} != "1" ]]; then
  was_active=0
  is_active=0
  case "$PREV_STATUS" in working|asking_permissions|waiting_user_answers) was_active=1;; esac
  case "$STATUS"      in working|asking_permissions|waiting_user_answers) is_active=1;;  esac
  attention_event=""
  if [[ $was_active -eq 0 && $is_active -eq 1 ]]; then
    attention_event="${FALCODE_ATTENTION_ENTER_EVENT:-waiting}"
  elif [[ $was_active -eq 1 && $is_active -eq 0 ]]; then
    attention_event="${FALCODE_ATTENTION_EXIT_EVENT:-completed}"
  fi
  if [[ -n $attention_event ]]; then
    ( zellij pipe --name "zellij-attention::${attention_event}::${PANE_ID}" >/dev/null 2>&1 & )
  fi
fi

# Notification via oc-notify.sh (macOS only; absent on Linux installs).
notify_status=""
case "$STATUS" in
  asking_permissions)
    notify_status="permission"
    ;;
  waiting_user_input)
    case "$PREV_STATUS" in working|asking_permissions|waiting_user_answers) notify_status="idle";; esac
    ;;
esac

if [[ -n $notify_status && -x $NOTIFY_SCRIPT ]]; then
  display_name="Codex"
  [[ -n $CWD ]] && display_name="$(basename "$CWD")"

  ( "$NOTIFY_SCRIPT" \
      --agent codex \
      --pane-name "$display_name" \
      --pane-title "" \
      --status "$notify_status" \
      --session "$SESSION_NAME" \
      --pane-id "$PANE_ID" >/dev/null 2>&1 & )
fi

exit 0
