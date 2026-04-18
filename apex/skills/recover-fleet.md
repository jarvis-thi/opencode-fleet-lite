# /recover-fleet

Troubleshoot a **down** or **unreachable** fleet agent (tmux missing, `comms/send.sh` errors, no reply after reasonable wait) and bring them back **without** asking the human to type shell commands by hand.

## Relationship to `ensure-fleet-up.sh`

**Normal path:** On **every user message**, Apex runs **`bash scripts/ensure-fleet-up.sh`** first (see `AGENT.md` **Fleet liveness**). That script sources **`comms/roster.sh`** and starts **every** roster peer that is DOWN — **Forge**, **Prism**, and **any spawned agent** listed in `ROSTER`.

Use **`/recover-fleet`** when automation is not enough: stuck panes, errors after start, or targeted diagnosis.

## Usage

```
/recover-fleet              # check all roster agents, fix any that are DOWN
/recover-agent <name>       # focus on one agent (e.g. forge, prism, scout)
```

## When to use

- After **`ensure-fleet-up.sh`** still leaves a peer DOWN or wedged.
- `comms/send.sh` prints `session ... not found` or similar.
- Delegation gets no ACK and `tmux has-session` fails.
- User says an agent is down, stuck, or unreachable.

## Procedure (execute with your shell tools)

### 1. Confirm fleet root and roster

- Working directory **`apex/`** (or `cd` there).
- Fleet root = `$(dirname "$(pwd)")`.
- **`comms/roster.sh`** is the **only** authoritative list of peers Apex must heal (Forge, Prism, future spawns). If an agent is missing from `ROSTER`, add it (or re-run **`/spawn-agent`** scope) before expecting auto-recovery.

### 2. Prefer the helper (if not already run this turn)

```bash
bash scripts/ensure-fleet-up.sh
```

### 3. Status check

From **fleet root**:

```bash
./status.sh
```

Or iterate manually after `source comms/roster.sh`:

```bash
for name in "${!ROSTER[@]}"; do
  s="${ROSTER[$name]}"
  tmux has-session -t "$s" 2>/dev/null && echo "$name:$s:UP" || echo "$name:$s:DOWN"
done
```

### 4. Start a missing peer (manual — matches `ensure-fleet-up.sh`)

For **`forge`** and **`prism`** only:

```bash
tmux new-session -d -s forge -c "$(dirname "$(pwd)")/forge" 'opencode --agent forge'
tmux new-session -d -s prism -c "$(dirname "$(pwd)")/prism" 'opencode --agent prism'
```

For **any other** roster name (spawned agents):

```bash
tmux new-session -d -s <session> -c "$(dirname "$(pwd)")/<name>" "opencode"
```

Use `ROSTER[name]` for the session name if it ever differs from `name` (default: same).

Run **only** for agents that are DOWN. If the session **exists** but is wedged, see **Stuck session** below.

### 5. After start — dismiss startup noise

```bash
sleep 5
tmux send-keys -t <session> Enter
```

### 6. Verify

```bash
tmux has-session -t <session> && tmux capture-pane -t <session> -p | tail -15
```

Optional ping:

```bash
./comms/send.sh <name> "INFO | Apex here — recovery complete. Reply ACK when you are ready. END"
```

### 7. Tell the user

Summary: who was DOWN, what you started, session name, `tmux attach -t <session>`.

### 8. Log

Append to `memory/log.md`: timestamp, agent, cause, action.

---

## Stuck session (UP but broken)

If `has-session` is true but the pane is frozen, error-looping, or `send.sh` delivers but there is no response:

1. **Capture evidence:** `tmux capture-pane -t <session> -p | tail -40`
2. **Soft recovery:** `INFO` / `REQUEST` via `comms/send.sh` if the UI allows clean exit.
3. **Hard recovery (last resort):** `tmux kill-session -t <session>`, then **`ensure-fleet-up.sh`** or the **new-session** lines from step 4.
4. **ESCALATE** if `opencode` is missing from `PATH` or the agent dir is gone.

---

## Principles

- **Apex does not write application code** — recovery is **ops**: tmux, paths, roster.
- **Do not** duplicate sessions: `has-session` before `new-session`.
- **Do not** ACK-chase a dead session — fix the session first.
- Missing agent **directory** — not fixable by tmux alone; **ESCALATE**.
