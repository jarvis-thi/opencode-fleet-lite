#!/usr/bin/env bash
# Fleet roster — maps logical agent name → tmux session name.
# Source of truth for: comms/send.sh targets, Apex fleet liveness (every user turn), status.sh, ensure-fleet-up.sh.
# When /spawn-agent adds a peer, this file MUST gain a new [name]="session" line (spawn-agent step 9).
declare -A ROSTER=(
  [forge]="forge"
  [prism]="prism"
  [mnemosyne]="mnemosyne"
)
