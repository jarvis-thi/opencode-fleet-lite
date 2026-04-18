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
./comms/send.sh forge "Build a REST API with user auth. Use Express + SQLite."
./comms/send.sh prism "Research the best auth libraries for Node.js. Report back."
./comms/send.sh vikki "REQUEST | Add ADR note for auth choice; link from fleet-wiki MOC. END"
./comms/send.sh forge "What's the status on the API build?"
```

## Message format

Always follow this structure:
```
[Apex to Forge] REQUEST | Build a REST API with CRUD endpoints.
Acceptance criteria: 4 endpoints, input validation, error handling.
Output to ../project/api/
END
```

The prefix `[Apex to Forge]` is added automatically by send.sh. You write the TYPE, body, and END.

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
- Be specific in REQUESTs: what to do, where to put output, acceptance criteria
- When you receive a message from another agent, it will appear in your terminal as `[Sender to You] TYPE | message END`

## Checking who's online

```bash
./comms/send.sh forge "Are you there?"
```

Or use the /status skill to check all tmux sessions.

## Reading another agent's terminal

To see what another agent is doing:
```bash
tmux capture-pane -t forge -p | tail -20
```

## Who can you talk to?

Any agent in the fleet. Check `comms/roster.sh` for the current list. If Apex spawns a new agent, the roster is updated automatically.

Currently: Forge (builder), Prism (analyst). More may be added at runtime.
