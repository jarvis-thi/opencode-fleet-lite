# opencode-fleet-lite

A small **example** drop-in fleet of three **OpenCode** agents that work together on your machine. Configure once, run `./start.sh`, then talk to the fleet in **one** place: **`tmux attach -t apex`**, or **Telegram** if you enable the optional bridge. **Apex** is the lead — Forge, Prism, and any agents you add later coordinate through that node so the fleet can ship work as a team.

**Lite on purpose:** there is **no** systemd and **no** watchdog to resurrect sessions after a reboot or a killed tmux pane. Detach when you are done (`Ctrl+B`, then `D`); whatever you leave running is what stays up. That keeps the repo easy to read and adapt without ops glue in the way.

Use it to learn the pattern — separate agent nodes, skills, and messages passing between them — then take it further: new roles, more agents, or your own hardening when you are ready.

Built for [OpenCode](https://github.com/sst/opencode). Model choice lives in **your** OpenCode setup, not in this repo.

---

## What you get

Three personalities, one mesh: you steer from **Apex**, the rest execute, cross-check, and can **ping each other directly** — delegation is not a one-way hose. Need another specialist? Ask Apex to **spawn** one; it wires the folder, prompt, tmux session, and roster so a new node joins the fleet without you hand-copying templates.

| Agent | Role |
|-------|------|
| **Apex** | **Strategist & your interface** — breaks down work, delegates, tracks outcomes. **You only attach here** (tmux or Telegram). |
| **Forge** | **Builder** — ships code, scripts, fixes; reports back when something is done or blocked. |
| **Prism** | **Analyst** — research, review, structured notes; curates shared memory the fleet can read. |
| **Anyone new** | Ask Apex (e.g. *“add an agent called Scout for security review”*). Apex creates the agent using **`/spawn-agent`** — folders, `AGENT.md`, tmux session, roster updates — you get a new node in the fleet without manual scaffolding. |

Forge and Prism come up when Apex needs them; you stay in **Apex** unless you *want* to peek at another pane. Optional **Telegram** still lands on Apex first.

**Who talks to whom**

You only message **Apex**. Inside the fleet, **any agent can message any agent** — Forge can ask Prism for a review, Prism can nudge Apex for a decision, and so on. Apex remains your single front door; behind it, the team is a **mesh**, not a strict ladder.

```
                         ┌──────────────────┐
           You (tmux) ──►│      Apex        │◄── optional Telegram
                         │   (your bridge)  │
                         └────────┬─────────┘
                    ┌─────────────┼─────────────┐
                    │             │             │
                    ▼             ▼             ▼
                 ┌──────┐     ┌──────┐     ┌──────────┐
                 │Forge │◄──►│Prism │◄──►│ Scout / … │  ← spawned on demand
                 └──┬───┘     └──┬───┘     └────┬─────┘
                    └───────────┼──────────────┘
                         any ⟷ any (peer messages)
```

---

## Prerequisites

- **OpenCode** installed and working, with **your LLM configured** (check with `opencode --version` and your usual provider setup).
- **tmux** — required; agents run inside tmux sessions.
- **Optional — for Telegram:** Node.js 20+ and npm (only if you enable the bridge).

---

## Install and run

Goal: **clone → `./start.sh` → attach to Apex** — no manual env file step. **`start.sh` creates `.env` from `.env.example` the first time** if needed. **Telegram is optional** — edit `.env` only when you want the bridge.

### Quick start (three steps)

1. **Clone and enter the repo**

   ```bash
   git clone https://github.com/jarvis-thi/opencode-fleet-lite.git fleet
   cd fleet
   ```

2. **Start the fleet**

   ```bash
   ./start.sh
   ```

   On first run, **`start.sh` creates `.env` from `.env.example`** if `.env` is missing — you do **not** copy anything by hand. Local use needs no edits; the file is there for when you add Telegram later.

   This launches **Apex** in tmux. **Forge** and **Prism** spin up when Apex needs them — not in this script.

3. **Talk to Apex**

   ```bash
   tmux attach -t apex
   ```

   Chat with Apex using your normal OpenCode workflow. Ask something small to start with (e.g. *“Summarise what this fleet can do”* or *“What would you delegate to Forge vs Prism?”*), then try a slightly larger task and watch Apex route work.

**Detach** without killing the session: **Ctrl+B**, then **D**.

That is enough to **see how things work** — Apex coordinates, other agents join when needed, and you stay in one session.

### How Apex should keep you updated

**Apex** is configured to communicate like a good lead operator:

- **Fast ack** — a short line so you know it heard you when the ask is non-trivial.
- **Says when it sends work to the fleet** — e.g. who it messaged (Forge / Prism / …) and for what.
- **Says when fleet work finishes** — outcome, result path, or blocker, in one clear update.

That applies **in tmux** (everything you read in the Apex pane) and, if you enable Telegram, **on Telegram** too (Apex replies via the bridge — not silent side effects).

### Optional: Telegram (only when you want it)

Skip this until you care about phone access. **`./start.sh` already created `.env`** — open it and set **`TELEGRAM_BOT_TOKEN`** and **`TELEGRAM_CHAT_ID`** (from @BotFather and your chat id).

Then:

```bash
cd telegram/bridge && npm install && cd ../..
./start.sh
```

That starts **`fleet-telegram`** if the token is set. Messages hit Apex the same way as in tmux; Apex should **still** ack, announce delegations, and close the loop when work completes.

You can use **Telegram-only** for chat if Apex is already running — no tmux attach required — but Apex must be up.

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

**Per agent:** each node has a `memory/` folder — **`bootstrap.md`** (context on boot), **`handoff.md`** (state you want next session to inherit), **`log.md`** (running trail). The agents write these as they work; you are not expected to curate them by hand unless you want to peek under the hood.

**Fleet-wide:** Prism curates **`prism/memory/shared.md`** — a shared surface the other agents read; treat it as the fleet’s lightweight wiki / notice board.

**Example, not scripture.** This layout is the **starter** wiring for OpenCode Fleet Lite. If you already have a preferred OpenCode memory pattern — different files, tooling, or habits — **ask Apex** to propagate it across the fleet and **update the skills** so Forge, Prism, and anyone spawned later all follow the same contract. Apex coordinates the retune; after that, you are on **your** memory setup, not ours.

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
