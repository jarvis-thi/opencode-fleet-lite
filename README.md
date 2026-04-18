# opencode-fleet-lite

A small, drop-in **fleet of three OpenCode agents** that work together from your machine. Configure once, run `./start.sh`, and talk to the fleet through **one** terminal session: **Apex**, the lead agent.

Built for [OpenCode](https://github.com/sst/opencode). Uses **your** existing OpenCode / LLM setup (model choice is not duplicated here).

---

## What you get

| Agent | Role |
|-------|------|
| **Apex** | Strategist and **your only day-to-day interface** — plans work, delegates, can add new agents on demand |
| **Forge** | Builder — implements and ships |
| **Prism** | Analyst — research, review, shared notes |

Forge and Prism run in their own tmux sessions when Apex brings them up; **you** do not need to attach to them to use the fleet. Optional **Telegram** talks to Apex the same way (messages are delivered into Apex’s session).

```
You  ──►  Apex (lead)  ──►  Forge / Prism / spawned agents
              ▲
       optional Telegram
```

---

## Prerequisites

- **OpenCode** installed and working, with **your LLM configured** (check with `opencode --version` and your usual provider setup).
- **tmux** — required; agents run inside tmux sessions.
- **Optional — for Telegram:** Node.js 20+ and npm (only if you enable the bridge).

---

## Install and run

### 1. Clone and enter the folder

```bash
git clone https://github.com/jarvis-thi/opencode-fleet-lite.git fleet
cd fleet
```

### 2. Configure environment

```bash
cp .env.example .env
```

Edit `.env`:

- Leave empty for a **local-only** fleet (no Telegram).
- To use **Telegram**, set `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` (see comments in `.env.example`).

### 3. (Optional) Install Telegram bridge dependencies

Only if you enabled Telegram in `.env`:

```bash
cd telegram/bridge && npm install && cd ../..
```

### 4. Start the fleet

```bash
./start.sh
```

This starts **Apex** in tmux. If Telegram is configured, it also starts the bridge in a separate tmux session. **Forge** and **Prism** are started by **Apex** when needed (not by `./start.sh` alone).

### 5. Talk to the fleet (tmux → Apex only)

```bash
tmux attach -t apex
```

Use your normal OpenCode flow inside that session. **Apex** is the node you speak with; it coordinates Forge and Prism for you.

Detach without closing the session: **Ctrl+B**, then **D**.

---

## Optional: Telegram

If `.env` has a bot token and chat id, `./start.sh` starts **`fleet-telegram`**. Messages go to **Apex**; Apex replies via the bundled MCP helper. You do not need to attach to tmux for Telegram use, but Apex must be running.

---

## Stop and check status

```bash
./status.sh   # which tmux sessions are up
./stop.sh     # graceful prompt, then stops apex / forge / prism / fleet-telegram
```

---

## Repository layout (overview)

```
fleet/
  start.sh   stop.sh   status.sh   .env
  apex/      # Lead agent — system prompt, skills, memory, comms helpers
  forge/     # Builder
  prism/     # Analyst + shared knowledge file
  telegram/  # Optional bridge (Grammy) + MCP for replies
```

Per-agent details live next to each agent (`AGENT.md`, `opencode.json`, `memory/`, `skills/`).

---

## Memory

Each agent keeps its own `memory/` (bootstrap, handoff, log). Prism maintains **`prism/memory/shared.md`** as fleet-wide notes other agents can read. You normally do not edit these by hand; agents update them as they work.

---

## Customization

| Goal | Where to look |
|------|----------------|
| Change tone or rules | Edit each agent’s `AGENT.md` |
| Change models | Your OpenCode / environment config (this repo does not pin a model) |
| Add another agent | Ask Apex to use **`/spawn-agent`** (see `apex/skills/spawn-agent.md`) |

---

## License

MIT
