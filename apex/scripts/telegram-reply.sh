#!/usr/bin/env bash
# Send a Telegram message using the Bot API (curl). Used when the bridge injects
# into Apex — OpenCode may not expose an MCP tool; this always works if .env is set.
#
# Usage (from apex/):
#   bash scripts/telegram-reply.sh "Your reply here"
#   bash scripts/telegram-reply.sh "Line one" "line two"   # joined with spaces
#
# Optional: override destination (defaults to TELEGRAM_CHAT_ID in .env):
#   TELEGRAM_CHAT_ID_OVERRIDE=123 bash scripts/telegram-reply.sh "hi"
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APEX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FLEET_DIR="$(cd "$APEX_DIR/.." && pwd)"
ENV_FILE="${FLEET_DIR}/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[telegram-reply] Missing ${ENV_FILE}" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

TOKEN="${TELEGRAM_BOT_TOKEN:-}"
CHAT="${TELEGRAM_CHAT_ID_OVERRIDE:-${TELEGRAM_CHAT_ID:-}}"

if [[ -z "$TOKEN" || -z "$CHAT" ]]; then
  echo "[telegram-reply] Set TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID in ${ENV_FILE}" >&2
  exit 1
fi

if [[ $# -eq 0 ]]; then
  echo "[telegram-reply] Usage: bash scripts/telegram-reply.sh <message>" >&2
  exit 1
fi

MSG="$*"
# Telegram hard limit ~4096 chars
if ((${#MSG} > 4000)); then
  echo "[telegram-reply] Warning: message is long; Telegram may truncate." >&2
fi

URL="https://api.telegram.org/bot${TOKEN}/sendMessage"
# Plain text — avoids Markdown parse errors on arbitrary content
RESP=$(curl -sS -X POST "$URL" \
  --data-urlencode "chat_id=${CHAT}" \
  --data-urlencode "text=${MSG}")
if ! echo "$RESP" | grep -q '"ok":true'; then
  echo "[telegram-reply] sendMessage failed:" >&2
  echo "$RESP" >&2
  exit 1
fi

echo "[telegram-reply] Sent."
