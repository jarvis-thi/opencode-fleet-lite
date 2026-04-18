#!/usr/bin/env bash
# Prism -> Agent message sender
# Usage: ./send.sh <agent> "message"
# Injection: temp file + tmux load-buffer / paste-buffer (portable; avoids set-buffer -t quirks).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/roster.sh"

SENDER="Prism"
TARGET="$1"
MESSAGE="$2"

SESSION="${ROSTER[$TARGET]:-}"
if [ -z "$SESSION" ]; then
  echo "Error: Unknown agent '$TARGET'. Known agents: ${!ROSTER[*]}"
  exit 1
fi

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Error: tmux session '$SESSION' not found. Agent may be offline."
  exit 1
fi

FORMATTED="[$SENDER to ${TARGET^}] $MESSAGE"
TMP=$(mktemp)
BUF="fleet-comms-${RANDOM}${RANDOM}"
printf '%s' "$FORMATTED" > "$TMP"
tmux load-buffer -b "$BUF" "$TMP"
rm -f "$TMP"
tmux paste-buffer -t "$SESSION" -b "$BUF"
tmux delete-buffer -b "$BUF" 2>/dev/null || true
sleep 0.5
tmux send-keys -t "$SESSION" Enter

echo "Sent to $TARGET ($SESSION)"
