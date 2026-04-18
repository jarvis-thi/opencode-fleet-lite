#!/usr/bin/env bash
# Ensure every agent in apex/comms/roster.sh has a live tmux session.
# Run from anywhere:  bash apex/scripts/ensure-fleet-up.sh
# Or from apex/:       bash scripts/ensure-fleet-up.sh
# Built-ins forge|prism use: opencode --agent <name>. All other roster names: opencode (spawn-agent contract).
# Extend the case if a new built-in needs a different invocation.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APEX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FLEET_DIR="$(cd "$APEX_DIR/.." && pwd)"

# shellcheck disable=SC1091
source "$APEX_DIR/comms/roster.sh"

started=()
attempted=0
for name in "${!ROSTER[@]}"; do
  sess="${ROSTER[$name]}"
  if tmux has-session -t "$sess" 2>/dev/null; then
    continue
  fi
  attempted=1
  agent_dir="$FLEET_DIR/$name"
  if [[ ! -d "$agent_dir" ]]; then
    echo "[ensure-fleet-up] SKIP $name — missing directory $agent_dir" >&2
    continue
  fi
  case "$name" in
    forge|prism)
      tmux new-session -d -s "$sess" -c "$agent_dir" "opencode --agent $name" || {
        echo "[ensure-fleet-up] ERROR failed to create session $sess" >&2
        continue
      }
      ;;
    *)
      tmux new-session -d -s "$sess" -c "$agent_dir" "opencode" || {
        echo "[ensure-fleet-up] ERROR failed to create session $sess" >&2
        continue
      }
      ;;
  esac
  sleep 5
  if tmux has-session -t "$sess" 2>/dev/null; then
    tmux send-keys -t "$sess" Enter 2>/dev/null || echo "[ensure-fleet-up] WARN send-keys failed for $sess" >&2
    started+=("$name")
  else
    echo "[ensure-fleet-up] WARN session $sess not running after start (opencode crash or missing?)" >&2
  fi
done

if ((${#started[@]})); then
  echo "[ensure-fleet-up] started: ${started[*]}"
elif ((attempted == 0)); then
  echo "[ensure-fleet-up] all roster sessions already UP"
else
  echo "[ensure-fleet-up] no new session completed this run — see WARN/ERROR above"
fi
