#!/usr/bin/env bash
# Apex -> Agent message sender
# Usage: ./send.sh <agent> "message"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/roster.sh"

SENDER="Apex"
TARGET="$1"
MESSAGE="$2"

# Resolve tmux session name
SESSION="${ROSTER[$TARGET]:-}"
if [ -z "$SESSION" ]; then
  echo "Error: Unknown agent '$TARGET'. Known agents: ${!ROSTER[*]}"
  exit 1
fi

# Check session exists
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Error: tmux session '$SESSION' not found. Agent may be offline."
  exit 1
fi

# Format and inject message
FORMATTED="[$SENDER to ${TARGET^}] $MESSAGE"
tmux set-buffer -t "$SESSION" "$FORMATTED" \; paste-buffer -t "$SESSION"
sleep 0.5
tmux send-keys -t "$SESSION" Enter

echo "Sent to $TARGET ($SESSION)"
