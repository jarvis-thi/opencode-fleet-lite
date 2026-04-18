#!/usr/bin/env bash
set -euo pipefail

FLEET_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$FLEET_DIR"

echo "=== OpenCode Fleet Lite ==="
echo ""

# Bootstrap .env from template so users never copy by hand
if [[ ! -f .env ]]; then
  if [[ -f .env.example ]]; then
    cp .env.example .env
    echo "[config] Created .env from .env.example (local-only defaults)"
    echo "[config] Edit .env when you want Telegram — then npm install in telegram/bridge and run ./start.sh again"
  else
    echo "[config] No .env or .env.example — continuing without env file"
  fi
fi

# Source config
if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
  echo "[config] Loaded .env"
fi

export FLEET_DIR

# Start Apex
if tmux has-session -t apex 2>/dev/null; then
  echo "[apex] Already running -- skipping"
else
  echo "[apex] Starting Apex agent..."
  tmux new-session -d -s apex -c "$FLEET_DIR/apex" "opencode"
  echo "[apex] Waiting for boot..."
  sleep 3
  tmux send-keys -t apex Enter
  echo "[apex] Started"
fi

# Start Telegram bridge (optional)
if [[ -n "${TELEGRAM_BOT_TOKEN:-}" ]]; then
  if tmux has-session -t fleet-telegram 2>/dev/null; then
    echo "[telegram] Bridge already running -- skipping"
  else
    echo "[telegram] Starting Telegram bridge..."
    tmux new-session -d -s fleet-telegram -c "$FLEET_DIR/telegram/bridge" "node src/index.js"
    echo "[telegram] Bridge started"
  fi
else
  echo "[telegram] No TELEGRAM_BOT_TOKEN set -- bridge disabled"
fi

echo ""
echo "=== Fleet Started ==="
echo ""
echo "  Talk to the fleet (tmux):  tmux attach -t apex   # Apex is the lead — your interface"
echo "  Other agents:            Apex runs scripts/ensure-fleet-up.sh every user turn (roster-driven)"
if [[ -n "${TELEGRAM_BOT_TOKEN:-}" ]]; then
  echo "  Telegram:                messages go to Apex (bridge session: fleet-telegram)"
fi
echo ""
echo "  Stop:     ./stop.sh"
echo "  Status:   ./status.sh"
