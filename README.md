# opencode-fleet-lite

A ready-to-run fleet of 3 AI agents that coordinate through tmux. Drop this folder anywhere, configure your `.env`, and start.

Built for [OpenCode](https://github.com/sst/opencode). Works with any LLM.

## What you get

```
You (Telegram)
     |
   APEX ---- strategist, plans and delegates
   / \
FORGE  PRISM
build  research
```

Three agents in tmux sessions. They talk by injecting messages into each other's terminals. You talk to Apex from Telegram. They remember context across restarts.

## Setup (5 minutes)

### Prerequisites

- OpenCode installed and working (`opencode --version`)
- tmux installed (`apt install tmux`)
- Node.js 20+ (for Telegram bridge)
- An LLM API key

### 1. Clone and configure

```bash
git clone https://github.com/jarvis-thi/opencode-fleet-lite.git fleet
cd fleet
cp .env.example .env
nano .env  # Set your API key and optional Telegram bot token
```

### 2. Start the fleet

```bash
./start.sh
```

That's it. Apex starts in a tmux session, then brings up Forge and Prism automatically. If you configured Telegram, the bridge starts too.

### 3. Talk to your fleet

**From Telegram** (if configured):
Send a message to your bot. Apex receives it, plans, and delegates.

**From terminal:**
```bash
tmux attach -t apex    # Talk to the strategist
tmux attach -t forge   # Talk to the builder
tmux attach -t prism   # Talk to the analyst
# Ctrl+B, D to detach
```

**Send a message between agents:**
```bash
./apex/comms/send.sh forge "Build a hello world API in Python"
```

## Folder structure

```
fleet/
  .env              # API key, model, Telegram token (optional)
  start.sh          # Starts Apex (who starts Forge + Prism)
  stop.sh           # Stops all 3 agents
  status.sh         # Shows who's running
  
  apex/             # The Strategist
    AGENT.md        # System prompt (identity + rules)
    opencode.json   # OpenCode config
    memory/         # Persistent context
    skills/         # Fleet coordination skills
    comms/          # Scripts to talk to other agents
    
  forge/            # The Builder
    AGENT.md
    opencode.json
    memory/
    skills/
    comms/
    
  prism/            # The Analyst
    AGENT.md
    opencode.json
    memory/
    skills/
    comms/
    
  telegram/         # Telegram bridge (optional)
    bridge/         # Grammy bot (Telegram -> Apex tmux)
    mcp/            # MCP server (agent -> Telegram reply)
```

## How agents communicate

Agents inject messages into each other's tmux sessions:

```bash
# Apex tells Forge to build something
[Apex to Forge] REQUEST | Build a REST API with CRUD endpoints. END
```

Forge sees this appear in their terminal, works on it, then replies:

```bash
# Forge reports back to Apex
[Forge to Apex] REPORT | API built at ./api/. 4 endpoints, tests passing. END
```

Message types:
- `REQUEST` -- needs action (always ACK these)
- `REPORT` -- status update
- `ACK` -- acknowledged (never ACK an ACK)
- `ESCALATE` -- needs the human
- `INFO` -- informational

## How memory works

Each agent has a `memory/` folder:

- `bootstrap.md` -- loaded at session start (what was I doing?)
- `handoff.md` -- written before shutdown (save context for next time)
- `log.md` -- running work log

Before stopping an agent, it writes its current context to `handoff.md`. On next start, `bootstrap.md` is regenerated from the handoff. Context is never lost.

Shared knowledge lives in `prism/memory/shared.md` -- all agents can read it.

## How Telegram works

If you set `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` in `.env`:

1. The bridge receives your message on Telegram
2. Wraps it in `<telegram>` tags and pastes into Apex's tmux
3. Apex processes it (may delegate to Forge/Prism)
4. Apex replies using the `telegram_reply` MCP tool
5. You see the response on your phone

Only your chat ID can talk to the bot. Secure by default.

## Customization

**Change personalities:** Edit `*/AGENT.md`

**Change models:** Uses whatever model you have configured in OpenCode. No separate config needed.

**Add a 4th agent:** Copy any agent folder, edit AGENT.md, add to the roster in each agent's comms config.

## License

MIT
