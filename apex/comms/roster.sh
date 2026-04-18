#!/usr/bin/env bash
# Fleet roster — maps logical agent name to tmux session name.
# Bash 3.2 compatible (no associative arrays).
# Usage: call roster_session <name> to get the tmux session name.
# Source of truth for: comms/send.sh targets, ensure-fleet-up.sh, status.sh.

roster_session() {
  case "$1" in
    forge) echo "forge" ;;
    prism) echo "prism" ;;
    # Optional: Vikki (wiki memory) — uncomment when ready
    # vikki) echo "vikki" ;;
    *) echo "" ;;
  esac
}

roster_all() {
  echo "forge prism"
}
