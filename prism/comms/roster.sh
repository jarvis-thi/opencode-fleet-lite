#!/usr/bin/env bash
# Fleet roster — peers Prism may message (logical name -> tmux session).
# Bash 3.2 compatible (no associative arrays).

roster_session() {
  case "$1" in
    apex) echo "apex" ;;
    forge) echo "forge" ;;
    *) echo "" ;;
  esac
}

roster_all() {
  echo "apex forge"
}
