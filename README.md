# opencode-fleet-lite

> **What this is**
>
> - A **simple example repo** for building a **fleet of agents** — real roles you name and keep, not a lottery of one-off sub-agents. Specialists that can grow with you.
> - **KISS** — *Keep It Simple, Stupid.* This is what worked for me, packaged so you might steal it and make your day a little easier.
> - **Imagination is the limit** — same pattern works for code, research, ops, creative stuff, chaos. Apply it to anything.

You need [OpenCode](https://github.com/sst/opencode) and **tmux**. Models live in *your* OpenCode config — this repo is just the crew.

---

## The crew (in plain English)

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

Optional **Telegram**: put your bot token and chat id in `.env`, `npm install` inside `telegram/bridge`, run `./start.sh` again. Same Apex — phone instead of tmux.

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

## License

MIT
