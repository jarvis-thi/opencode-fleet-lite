#!/usr/bin/env bash
set -euo pipefail

SESSIONS=(apex forge prism fleet-telegram)

echo "=== Stopping OpenCode Fleet Lite ==="
echo ""

# Send graceful handoff request to agent sessions
for session in apex forge prism; do
  if tmux has-session -t "$session" 2>/dev/null; then
    echo "[$session] Sending handoff request..."
    tmux send-keys -t "$session" "Save your state and prepare for shutdown." Enter
  fi
done

# Wait for agents to wrap up
active=0
for session in "${SESSIONS[@]}"; do
  tmux has-session -t "$session" 2>/dev/null && ((active++)) || true
done

if [[ $active -gt 0 ]]; then
  echo ""
  echo "[fleet] Waiting 5s for graceful handoff..."
  sleep 5
fi

# Kill all sessions
echo ""
for session in "${SESSIONS[@]}"; do
  if tmux has-session -t "$session" 2>/dev/null; then
    tmux kill-session -t "$session"
    echo "[$session] Stopped"
  else
    echo "[$session] Not running"
  fi
done

echo ""
echo "=== Fleet Stopped ==="
