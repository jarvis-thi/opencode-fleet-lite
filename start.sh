#!/usr/bin/env bash
set -euo pipefail

FLEET_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$FLEET_DIR"

echo "=== OpenCode Fleet Lite ==="
echo ""

# Source config
if [[ -f .env ]]; then
  set -a
  source .env
  set +a
  echo "[config] Loaded .env"
else
  echo "[config] No .env found -- using environment defaults"
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
echo "  Forge / Prism:           started by Apex when needed (you normally stay in apex)"
if [[ -n "${TELEGRAM_BOT_TOKEN:-}" ]]; then
  echo "  Telegram:                messages go to Apex (bridge session: fleet-telegram)"
fi
echo ""
echo "  Stop:     ./stop.sh"
echo "  Status:   ./status.sh"
