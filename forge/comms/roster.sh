#!/usr/bin/env bash
# Fleet roster — peers Forge may message (logical name -> tmux session).
# Bash 3.2 compatible (no associative arrays).

roster_session() {
  case "$1" in
    apex) echo "apex" ;;
    prism) echo "prism" ;;
    *) echo "" ;;
  esac
}

roster_all() {
  echo "apex prism"
}
