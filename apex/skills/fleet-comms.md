# Fleet Comms

How to communicate with other agents in the fleet.

## CRITICAL — Response Reflex Rule

**When you receive a `[X to Apex]` formatted message in your terminal, your ONLY valid response is:**

```bash
bash comms/send.sh <sender> "<TYPE> | <your response> END"
```

**NEVER reply to a fleet message by typing in your own terminal.** The sender cannot read your terminal. The only way they see your response is via `comms/send.sh`.

## How it works

You share a server with other agents. Each agent runs in its own tmux session. You talk to them by injecting messages into their terminal using `bash comms/send.sh`.

When you send a message, it appears in the other agent's terminal as if someone typed it. They read it, process it, and **must** reply the same way back to you via their own `comms/send.sh`.

## Sending a message

```bash
bash comms/send.sh <agent> "<TYPE> | <message body> END"
```

Examples:
```bash
bash comms/send.sh forge "REQUEST | Build a REST API with user auth. Use Express + SQLite. END"
bash comms/send.sh prism "REQUEST | Research the best auth libraries for Node.js. Report back. END"
bash comms/send.sh vikki "REQUEST | Add ADR note for auth choice; link from fleet-wiki MOC. END"
```

## Receiving a message

When a message appears in your terminal like:
```
[Forge to Apex] REPORT | API build complete. 4 endpoints done. END
```

You MUST respond ONLY by running:
```bash
bash comms/send.sh forge "ACK | Thanks. END"
```

**Do NOT just type your response in the terminal. The sender will not see it.**

## Message format

All messages follow this structure:
```
[Apex to <Receiver>] <TYPE> | <message body> END
```

The prefix `[Apex to <Receiver>]` is added automatically by send.sh. You write the TYPE, body, and END.

## Message types

| Type | When to use | Expects reply? |
|------|------------|----------------|
| REQUEST | You need another agent to do something | Yes (ACK + result) |
| REPORT | Sharing a status update or findings | No |
| ACK | Confirming you received a message | No |
| ESCALATE | Problem that needs the human | No |
| INFO | Sharing context, no action needed | No |

## Rules

1. **ALWAYS use `bash comms/send.sh` to reply. Never type a reply directly.**
2. Always ACK a REQUEST (even a short "On it.")
3. Never ACK an ACK (prevents infinite loops)
4. End every message with `END`
5. Be specific in REQUESTs: what to do, where to put output, acceptance criteria
6. When you receive a message from another agent, it will appear in your terminal as `[Sender to Apex] TYPE | message END`

## Checking who's online

```bash
bash scripts/ensure-fleet-up.sh
```

Or use the /status skill to check all tmux sessions.

## Reading another agent's terminal

To see what another agent is doing:
```bash
tmux capture-pane -t forge -p | tail -20
```

## Who can you talk to?

Any agent in the fleet. Check `comms/roster.sh` for the current list. If Apex spawns a new agent, the roster is updated automatically.

Currently: Forge (builder), Prism (analyst). Vikki (wiki) optional. More may be added at runtime.
