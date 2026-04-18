# /spawn-agent

Spawn a new agent into the fleet on demand.

## Usage
```
/spawn-agent <name> "<role description>"
```

## Examples
```
/spawn-agent scout "Security auditor -- reviews code for vulnerabilities, scans infrastructure, reports threats"
/spawn-agent herald "Communications officer -- drafts announcements, release notes, changelogs"
```

## Procedure

When the user asks you to create a new agent (e.g. "create a new agent called Scout for security auditing"), follow these steps exactly. Use your shell tools to execute each step -- do not generate code for the user to run.

### 1. Validate the name

- Lowercase the agent name (e.g. "Scout" becomes "scout").
- Check that `../scout/` does not already exist. If it does, report the conflict and stop.
- Check that a tmux session named `scout` does not already exist.

### 2. Create the agent folder

Copy the folder structure from an existing agent as a template:

```bash
mkdir -p ../scout/{memory,skills,comms}
```

### 3. Write AGENT.md

Create `../scout/AGENT.md` with content tailored to the requested role. Follow this structure:

```markdown
# <Name> -- <Role Title>

## Identity
You are <Name>, the fleet <role>. <2-3 sentences describing personality and approach based on what the user asked for.>

## Voice
<1-2 sentences on communication style appropriate to the role.>

## Fleet Roster
| Agent | Role | TMux Session | Path |
|-------|------|-------------|------|
<List ALL existing agents plus Apex. Get the current roster from your own AGENT.md.>

## Communication Protocol
All inter-agent messages use this format:
\```
[<Name> to <Receiver>] <TYPE> | <message body> END
\```

Types:
- REQUEST -- needs action (always ACK)
- REPORT -- status/findings
- ACK -- acknowledged (never ACK an ACK)
- ESCALATE -- needs the human
- INFO -- informational

Use `comms/send.sh <agent> "message"` to send messages.

## Memory Rules
- **Session start:** Read `memory/bootstrap.md`.
- **During work:** Append progress to `memory/log.md`.
- **Session end:** Write a summary to `memory/handoff.md`.

## User Access
You can receive tasks from Apex or directly from the user via tmux. You do not have Telegram access -- communicate with Apex and other agents through tmux injection (comms/send.sh). The user talks to you by attaching to your tmux session or through Apex.

## Shared Knowledge
Read `../prism/memory/shared.md` for fleet knowledge maintained by Prism. Send findings to Prism for inclusion.

## Principles
<3-5 principles appropriate to the agent's role.>
```

### 4. Write opencode.json

Create `../scout/opencode.json`:

```json
{
  "systemPrompt": "AGENT.md",
  "mcpServers": {}
}
```

### 5. Create comms/send.sh

Create `../scout/comms/send.sh` with the standard sender script. Use the existing `forge/comms/send.sh` as a template -- copy it and replace `SENDER="Forge"` with `SENDER="Scout"` (capitalised).

Make it executable:
```bash
chmod +x ../scout/comms/send.sh
```

### 6. Create comms/roster.sh

Create `../scout/comms/roster.sh` listing ALL other agents:

```bash
#!/usr/bin/env bash
# Fleet roster -- maps agent names to tmux session names
declare -A ROSTER=(
  [apex]="apex"
  [forge]="forge"
  [prism]="prism"
  # ... include any other agents that exist
)
```

### 7. Create initial memory files

```bash
echo "# Bootstrap\n\nNew agent. No prior context." > ../scout/memory/bootstrap.md
touch ../scout/memory/log.md
touch ../scout/memory/handoff.md
```

### 8. Start the agent

```bash
tmux new-session -d -s scout -c "$(pwd)/../scout" "opencode"
```

Wait 5 seconds, then send Enter to dismiss any startup prompt:
```bash
sleep 5
tmux send-keys -t scout Enter
```

### 9. Update ALL existing agents' rosters

For EVERY existing agent (forge, prism, and any others), update their `comms/roster.sh` to include the new agent. Also update **your own** `apex/comms/roster.sh`.

**Critical:** `apex/comms/roster.sh` is the **source of truth** for **`scripts/ensure-fleet-up.sh`** and Apex’s **every user message** fleet sweep. If the new peer is not in **Apex’s** `ROSTER`, they will **not** be auto-started when DOWN.

For each agent's roster file, add the new entry:
```
  [scout]="scout"
```

Also update the Fleet Roster table in your own AGENT.md to include the new agent (optional for humans; liveness follows `roster.sh`).

### 10. Welcome the new agent

Send a welcome message to the new agent introducing it to the fleet:

```bash
comms/send.sh scout "INFO | Welcome to the fleet. You are Scout, our security auditor. The fleet currently has: Apex (strategist), Forge (builder), Prism (analyst), and you. Read your AGENT.md for your full brief. Report to Apex when you are ready. END"
```

### 11. Report to the user

Tell the user:
- Agent name and role
- Folder created at `../scout/`
- tmux session name: `scout`
- How to attach: `tmux attach -t scout`
- That the fleet roster has been updated across all agents
