# Fleet Comms

How to communicate with other agents in the fleet.

## CRITICAL — Response Reflex Rule

**When you receive a `[X to You]` formatted message in your terminal, your ONLY valid response is:**

```bash
bash comms/send.sh <sender> "<TYPE> | <your response> END"
```

**NEVER type a reply directly in your own terminal.** Fleet messages come from other agents — they cannot read your terminal output. The only way they see your response is if you inject it into their tmux session via `comms/send.sh`.

If you type a reply without running `comms/send.sh`, the sender will never see it. This is the single most important rule of fleet communication.

## How it works

You share a server with other agents. Each agent runs in its own tmux session. You talk to them by injecting messages into their terminal using `bash comms/send.sh`.

When you send a message, it appears in the other agent's terminal as if someone typed it. They read it, process it, and **must** reply the same way back to you via their own `comms/send.sh`.

## Sending a message

```bash
bash comms/send.sh <agent> "<TYPE> | <message body> END"
```

Examples:
```bash
bash comms/send.sh apex "REPORT | Research complete. Found 3 viable auth libraries. END"
bash comms/send.sh forge "REPORT | Review done on auth.ts. 2 critical issues, 1 warning. END"
bash comms/send.sh apex "REPORT | Recommending Passport.js over Auth0 SDK for this project. END"
```

## Receiving a message

When a message appears in your terminal like:
```
[Apex to Prism] REQUEST | Research auth libraries END
```

You MUST respond ONLY by running:
```bash
bash comms/send.sh apex "ACK | On it. END"
```

Then do the work, then report back:
```bash
bash comms/send.sh apex "REPORT | Research complete. Recommending Passport.js. END"
```

**Do NOT just type your response in the terminal. The sender will not see it.**

## Message format

All messages follow this structure:
```
[<Sender> to <Receiver>] <TYPE> | <message body> END
```

The prefix `[<Sender> to <Receiver>]` is added automatically by send.sh. You write the TYPE, body, and END.

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
5. Structure findings clearly when reporting — summary first, details after
6. When you receive a message from another agent, it will appear in your terminal as `[Sender to You] TYPE | message END`

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

## When to talk directly vs through Apex

- Forge asks for a review? Respond to Forge directly.
- Found something Forge needs to fix? Message Forge directly.
- Research results that inform planning? Message Apex.
- Updated shared knowledge? Message both Apex and Forge with an INFO.
- Something is wrong and needs the human? Message Apex to ESCALATE.
