#!/usr/bin/env bash
# Fleet roster — peers this agent may message (logical name → tmux session).
# Keep in sync with apex/comms/roster.sh for fleet-wide agent names.
declare -A ROSTER=(
  [apex]="apex"
  [prism]="prism"
  [mnemosyne]="mnemosyne"
)
