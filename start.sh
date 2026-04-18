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

# Prerequisites — fail fast with a clear message (avoids "no server / no sessions" when the
# session dies because opencode was missing or exited immediately).
if ! command -v tmux >/dev/null 2>&1; then
  echo "[error] tmux not found. Install it first (macOS: brew install tmux)" >&2
  exit 1
fi
if ! command -v opencode >/dev/null 2>&1; then
  echo "[error] opencode not found in PATH." >&2
  echo "        Install OpenCode from https://github.com/sst/opencode and ensure the CLI is on your PATH." >&2
  echo "        Quick check: run  opencode --version  in this terminal, then ./start.sh again." >&2
  exit 1
fi

# Start Apex
if tmux has-session -t apex 2>/dev/null; then
  echo "[apex] Already running -- skipping"
else
  echo "[apex] Starting Apex agent..."
  tmux new-session -d -s apex -c "$FLEET_DIR/apex" "opencode"
  echo "[apex] Waiting for boot..."
  sleep 3
  if ! tmux has-session -t apex 2>/dev/null; then
    echo "[error] Apex tmux session did not stay up." >&2
    echo "        Usually: opencode crashed or exited immediately (missing auth, bad config)." >&2
    echo "        Try by hand:  cd \"$FLEET_DIR/apex\" && opencode" >&2
    exit 1
  fi
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
echo "  Other agents:            Apex runs scripts/ensure-fleet-up.sh every user turn (forge, prism, optional peers in roster)"
if [[ -n "${TELEGRAM_BOT_TOKEN:-}" ]]; then
  echo "  Telegram:                messages go to Apex (bridge session: fleet-telegram)"
fi
echo ""
echo "  Stop:     ./stop.sh"
echo "  Status:   ./status.sh"
