#!/usr/bin/env bash
set -euo pipefail

echo "=== OpenCode Fleet Lite Status ==="
echo ""
printf "  %-20s %s\n" "AGENT" "STATUS"
printf "  %-20s %s\n" "----" "------"

for session in apex forge prism fleet-telegram; do
  if tmux has-session -t "$session" 2>/dev/null; then
    status="UP"
  else
    status="DOWN"
  fi
  printf "  %-20s %s\n" "$session" "$status"
done

echo ""
