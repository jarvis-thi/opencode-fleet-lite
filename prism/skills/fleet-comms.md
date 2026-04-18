# Fleet Comms

How to communicate with other agents in the fleet.

## How it works

You share a server with other agents. Each agent runs in its own tmux session. You talk to them by injecting messages into their terminal using `comms/send.sh`.

When you send a message, it appears in the other agent's terminal as if someone typed it. They read it, process it, and reply the same way back to you.

## Sending a message

```bash
./comms/send.sh <agent> "<message>"
```

Examples:
```bash
./comms/send.sh apex "Research complete. Found 3 viable auth libraries. Sending findings."
./comms/send.sh forge "Review done on auth.ts. 2 critical issues, 1 warning. Details below."
./comms/send.sh apex "Recommending Passport.js over Auth0 SDK. Lower complexity, sufficient for our scale."
```

## Message format

Always follow this structure:
```
[Prism to Apex] REPORT | Auth library research complete.

FINDINGS:
- Passport.js: mature, 50K+ GitHub stars, wide middleware support
- Auth0 SDK: managed service, simpler but vendor lock-in
- Lucia: lightweight, newer, good for small projects

RECOMMENDATION:
Passport.js for this project. Most flexible, best community support.

SOURCES:
- npm trends comparison (April 2026)
- Auth0 vs self-hosted comparison (Dev.to)
END
```

The prefix `[Prism to Apex]` is added automatically by send.sh. You write the TYPE, body, and END.

## Message types

| Type | When to use | Expects reply? |
|------|------------|----------------|
| REQUEST | You need another agent to do something | Yes (ACK + result) |
| REPORT | Sharing a status update or findings | No |
| ACK | Confirming you received a message | No |
| ESCALATE | Problem that needs the human | No |
| INFO | Sharing context, no action needed | No |

## Rules

- Always ACK a REQUEST (even a short "On it.")
- Never ACK an ACK (prevents infinite loops)
- End every message with `END` on its own line
- Structure your findings clearly when reporting -- summary first, details after
- When you receive a message from another agent, it will appear in your terminal as `[Sender to You] TYPE | message END`

## Checking who's online

```bash
tmux has-session -t apex 2>/dev/null && echo "Apex: UP" || echo "Apex: DOWN"
tmux has-session -t forge 2>/dev/null && echo "Forge: UP" || echo "Forge: DOWN"
```

## Reading another agent's terminal

To see what another agent is doing:
```bash
tmux capture-pane -t forge -p | tail -20
```

## Who can you talk to?

Any agent in the fleet. Check `comms/roster.sh` for the current list.

Currently: Apex (strategist), Forge (builder). More may be added at runtime by Apex.

## When to talk directly vs through Apex

- Forge asks for a review? Respond to Forge directly.
- Found something Forge needs to fix? Message Forge directly.
- Research results that inform planning? Message Apex.
- Updated shared knowledge? Message both Apex and Forge with an INFO.
- Something is wrong and needs the human? Message Apex to ESCALATE.
