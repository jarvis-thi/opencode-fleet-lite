# opencode-fleet-lite

> **What this is**
>
> - A **simple example repo** for building a **fleet of agents** — real roles you name and keep, not a lottery of one-off sub-agents. Specialists that can grow with you.
> - **KISS** — *Keep It Simple, Stupid.* This is what worked for me, packaged so you might steal it and make your day a little easier.
> - **Imagination is the limit** — same pattern works for code, research, ops, creative stuff, chaos. Apply it to anything.

You need [OpenCode](https://github.com/sst/opencode) and **tmux**. Models live in *your* OpenCode config — this repo is just the crew.

---

## The crew (in this random example)

| Who | Job |
|-----|-----|
| **Apex** | Your **only** door. You talk here. Plans, splits work, nags people, reports back. |
| **Forge** | Builds things — code, scripts, fixes. |
| **Prism** | Thinks — research, reviews, notes. Keeps a short shared scratchpad the fleet can read. |
| **Vikki** | Optional. Long-term wiki memory (markdown vault). Off by default — turn her on only if you want that. |

Everyone else is optional — Apex can add new specialists when you ask. Under the hood they’re just separate **tmux** sessions talking to each other like grown-ups (no fancy message bus, which means fewer things to break at 2am).

---

## Run it

```bash
git clone https://github.com/jarvis-thi/opencode-fleet-lite.git fleet
cd fleet
./start.sh
tmux attach -t apex
```

**Before `./start.sh`:** install **tmux** and **OpenCode** so both `tmux -V` and **`opencode --version`** work in the same terminal you use for the fleet (macOS: `brew install tmux`, then install OpenCode per its docs). If **`opencode` is not on your PATH**, the Apex pane exits straight away, tmux tears down the last session, and the next command moans about **no server / no sessions** — that is almost always “CLI not found or crashed,” not a broken script.

First run creates a `.env` for you. Detach without murdering the session: **Ctrl+B**, then **D**.

Check what’s alive: `./status.sh`. Wind down: `./stop.sh`.

---

## How to talk to Apex (and actually get stuff done)

**You only chat with Apex.** Don’t hop into Forge’s pane unless you’re debugging — Apex is the coordinator.

- **Say what you want**, in normal words. Bad: “do the thing.” Good: “Add a health endpoint to `server.ts` and tell me what you changed.”
- **Say who should do it** if you care — “have Forge implement it” or “have Prism review the auth module first.” If you don’t care, Apex picks.
- **Ask for a plan** when it’s big — “break this into steps and tell me who does what.”
- **Ask for silence to end** — “tell me when the whole thing is done” so you’re not pinged every thirty seconds.
- **Add a specialist** — “add an agent for X” or “we need someone who only does security reviews.” Apex wires folders, prompts, and the roster. You don’t need to be a YAML monk.

If Apex goes quiet, it’s probably thinking or waiting on Forge/Prism. A gentle “status?” is fair game.

Want **Telegram** instead of (or as well as) tmux? Setup and commands are at the bottom.

---

## What’s in the box

```
fleet/
  start.sh   stop.sh   status.sh
  apex/      # you talk here
  forge/     # builds
  prism/     # thinks + shared notes
  vikki/     # optional wiki vault — see vikki/SETUP.md
  telegram/  # optional bridge
```

Each agent has `AGENT.md`, `memory/`, and `skills/` — that’s how personalities and habits live. Tweak by editing markdown or by asking Apex to do it.

---

## Vikki (wiki memory) — optional

Want durable linked notes instead of only Prism’s quick board? Read **`vikki/SETUP.md`**. Apex can enable her by updating rosters — you don’t have to hand-merge five files unless you enjoy that.

---

## Telegram — setup and run

1. **Create a bot** in Telegram: talk to **@BotFather**, `/newbot`, copy the **bot token**.

2. **Get your chat id** (the account allowed to talk to the bot). Easiest: message **@userinfobot** (or similar) and copy the **numeric id** — that goes in `TELEGRAM_CHAT_ID`.

3. **Put secrets in `.env`** at the fleet repo root (same folder as `start.sh`). If you don’t have `.env` yet, `./start.sh` creates it from `.env.example` — then edit:

   ```
   TELEGRAM_BOT_TOKEN=123456:ABC...your_token_here
   TELEGRAM_CHAT_ID=123456789
   ```

4. **Install bridge deps once:**

   ```bash
   cd telegram/bridge && npm install && cd ../..
   ```

5. **Start (or restart) everything** — this launches Apex and, if `TELEGRAM_BOT_TOKEN` is set, the **fleet-telegram** tmux session:

   ```bash
   ./start.sh
   ```

Messages go to **Apex** the same as in tmux; you can chat from your phone without attaching. To see whether the bridge is up: `./status.sh` (look for `fleet-telegram`) or `tmux ls`.

---

## Setting up systemd

This repo stays **bare bones on purpose** — `./start.sh` and tmux, no babysitter. That’s great until a reboot eats your sessions and you’re doing archaeology at midnight.

**Strong suggestion:** once your fleet actually runs the way you like (clone, env, maybe Telegram), **ask Apex to wire systemd for you** — a unit that starts the fleet on boot and keeps it alive without you hand-checking tmux. Think: a service that runs your start path, plus whatever “watchdog” pattern fits your box (`Restart=`, a small health loop, or both). Paths and user differ per machine; Apex can draft the unit files and ordering so you’re not copy-pasting blind.

**Nudge:** you don’t have to become a unit-file monk — tell Apex something like “set up systemd so this fleet survives reboot on this machine” and it will follow **`apex/skills/systemd-fleet.md`** (OS-aware: Linux systemd, macOS launchd, not one template for everything).

You do the fun stuff first; automation second. Until then, `./start.sh` still works.

---

## License

MIT
