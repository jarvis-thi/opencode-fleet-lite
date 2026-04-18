#!/usr/bin/env bash
set -euo pipefail

FLEET_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$FLEET_DIR/apex/comms/roster.sh"

echo "=== OpenCode Fleet Lite Status ==="
echo ""
printf "  %-20s %s\n" "AGENT" "STATUS"
printf "  %-20s %s\n" "----" "------"

if tmux has-session -t apex 2>/dev/null; then
  apex_st="UP"
else
  apex_st="DOWN"
fi
printf "  %-20s %s\n" "apex" "$apex_st"

for name in $(roster_all); do
  sess="$(roster_session "$name")"
  if tmux has-session -t "$sess" 2>/dev/null; then
    st="UP"
  else
    st="DOWN"
  fi
  printf "  %-20s %s\n" "$name ($sess)" "$st"
done

if tmux has-session -t fleet-telegram 2>/dev/null; then
  tg="UP"
else
  tg="DOWN"
fi
printf "  %-20s %s\n" "fleet-telegram" "$tg"

echo ""
