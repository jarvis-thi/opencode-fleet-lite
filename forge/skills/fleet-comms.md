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
./comms/send.sh apex "API build complete. 4 endpoints, tests passing."
./comms/send.sh prism "Can you review the auth middleware at ../project/src/auth.ts?"
./comms/send.sh apex "Blocked on database creds. Need the connection string."
```

## Message format

Always follow this structure:
```
[Forge to Apex] REPORT | API build complete.
4 endpoints implemented: GET/POST/PUT/DELETE /users
Tests: 12/12 passing
Output at ../project/api/
END
```

The prefix `[Forge to Apex]` is added automatically by send.sh. You write the TYPE, body, and END.

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
- Report completion immediately -- never go silent after finishing
- When you receive a message from another agent, it will appear in your terminal as `[Sender to You] TYPE | message END`

## Checking who's online

```bash
tmux has-session -t apex 2>/dev/null && echo "Apex: UP" || echo "Apex: DOWN"
tmux has-session -t prism 2>/dev/null && echo "Prism: UP" || echo "Prism: DOWN"
```

## Reading another agent's terminal

To see what another agent is doing:
```bash
tmux capture-pane -t prism -p | tail -20
```

## Who can you talk to?

Any agent in the fleet. Check `comms/roster.sh` for the current list.

Currently: Apex (strategist), Prism (analyst). More may be added at runtime by Apex.

## When to talk directly vs through Apex

- Need a code review? Message Prism directly.
- Need context or research? Message Prism directly.
- Reporting task completion? Message Apex (he tracks tasks).
- Blocked and need help? Message Apex (he can re-scope or escalate).
- General question for anyone? Message whoever is most relevant.
