# opencode-fleet-lite

## Overview

Teaching **OpenCode + tmux** “fleet lite” pattern: Apex (lead), Forge (build), Prism (analyse), optional Vikki (wiki memory). Coordination is **tmux paste-buffer injection** between sessions — no separate message bus. Optional **Telegram** bridge hits Apex. Canonical user story: clone → `./start.sh` → `tmux attach -t apex`.

**Remote:** `https://github.com/jarvis-thi/opencode-fleet-lite`

## Current state

- **Repo:** Documented in `README.md` (roles, comms protocol, optional Vikki wiki agent, `/spawn-agent`, `/tune-fleet`).
- **Hel1 workspace clone:** `/root/projects/opencode-fleet-lite` (tracks `origin/main`).
- **Hel1 runtime check (2026-04-18):** `tmux` present; **`opencode` CLI not found in PATH** — `./start.sh` can create the Apex session but agents expect a working OpenCode install. Install or symlink OpenCode on this host before treating the fleet as runnable here.
- **Telegram:** Optional `telegram/bridge` + MCP; requires `TELEGRAM_*` in `.env` and `npm install` under `telegram/bridge` per README.

## Next steps

1. **Hel1:** Install OpenCode (or document exact path if installed non-globally) and smoke-test `./start.sh` + `./status.sh`.
2. **Product:** Keep Vikki optional (default roster excludes her); enable only on request (see `vikki/SETUP.md`).
3. **Integration:** If this should align with **jarvis-mesh** on the fleet, define whether this repo stays a standalone teaching fork or gains shared scripts.

## Open questions

- Should Apex `ensure-fleet-up` behaviour be gated when peers are intentionally stopped?
- Long-term home: keep as public teaching repo only, or promote to fleet-internal ops?

## Decisions

- **KISS transport:** tmux-only mesh, no systemd in-repo (documented in README).
