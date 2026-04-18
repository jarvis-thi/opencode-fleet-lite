#!/usr/bin/env bash
# Forge -> Agent message sender
# Usage: bash comms/send.sh <agent> "message"
# Bash 3.2 compatible.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/roster.sh"

SENDER="Forge"
TARGET="$1"
MESSAGE="$2"

SESSION="$(roster_session "$TARGET")"
if [ -z "$SESSION" ]; then
  echo "Error: Unknown agent '$TARGET'. Known agents: $(roster_all)"
  exit 1
fi

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Error: tmux session '$SESSION' not found. Agent may be offline."
  exit 1
fi

TITLED="$(echo "${TARGET:0:1}" | tr '[:lower:]' '[:upper:]')${TARGET:1}"
FORMATTED="[$SENDER to $TITLED] $MESSAGE"
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
