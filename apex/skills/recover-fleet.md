# /recover-fleet

Troubleshoot a **down** or **unreachable** fleet agent (tmux missing, `comms/send.sh` errors, no reply after reasonable wait) and bring them back **without** asking the human to type shell commands by hand.

## Usage

```
/recover-fleet              # check all roster agents, fix any that are DOWN
/recover-agent <name>       # focus on one agent (e.g. forge, prism, scout)
```

## When to use

- `comms/send.sh` prints `session ... not found` or similar.
- Delegation or fleet ping gets no ACK and `tmux has-session -t <session>` fails.
- User says an agent is down, stuck, or unreachable.
- After host reboot — pair with normal **Startup** in `AGENT.md`, but use this skill if only **some** agents are missing.

## Procedure (execute with your shell tools)

### 1. Confirm fleet root and roster

- Your working directory should be **`apex/`** (or `cd` there first).
- Fleet root = `$(dirname "$(pwd)")` — parent of `apex/`.
- Source roster: `source comms/roster.sh` — `ROSTER` maps logical names to tmux session names.
- For every agent **except apex**, the expected session name is `ROSTER[name]`.

### 2. Status check

From **fleet root** (parent of `apex/`):

```bash
./status.sh
```

Or per session:

```bash
tmux has-session -t forge 2>/dev/null && echo forge:UP || echo forge:DOWN
tmux has-session -t prism 2>/dev/null && echo prism:UP || echo prism:DOWN
```

For **spawned** agents not in `status.sh`’s fixed list, check the session name from `comms/roster.sh` and run `has-session` for each.

### 3. Start a missing **Forge** or **Prism**

Use the **same** commands as **Startup** in `AGENT.md` (paths must match):

```bash
tmux new-session -d -s forge -c "$(dirname "$(pwd)")/forge" 'opencode --agent forge'
tmux new-session -d -s prism -c "$(dirname "$(pwd)")/prism" 'opencode --agent prism'
```

Run **only** for agents that are DOWN. If the session **exists** but is wedged, see **Stuck session** below.

### 4. Start a missing **spawned** agent

If `../<name>/` exists (folder layout from `/spawn-agent`):

```bash
tmux new-session -d -s <name> -c "$(dirname "$(pwd)")/<name>" "opencode"
```

Use the **session name** from `../<name>/comms/roster.sh` if it differs (it should match the tmux `-s` name).

### 5. After start — dismiss startup noise

```bash
sleep 5
tmux send-keys -t <session> Enter
```

### 6. Verify

```bash
tmux has-session -t <session> && tmux capture-pane -t <session> -p | tail -15
```

Optional: ping the agent:

```bash
./comms/send.sh <name> "INFO | Apex here — recovery complete. Reply ACK when you are ready. END"
```

### 7. Tell the user

One short summary: who was DOWN, what you started, session name, and how to attach (`tmux attach -t <session>`) if they want to watch.

### 8. Log

Append a line to `memory/log.md`: timestamp, agent, cause if known, action taken.

---

## Stuck session (UP but broken)

If `has-session` is true but the pane is frozen, error-looping, or `send.sh` delivers but the agent never responds:

1. **Capture evidence:** `tmux capture-pane -t <session> -p | tail -40` — look for stack traces, auth errors, missing `opencode`.
2. **Prefer soft recovery:** send an `INFO` or `REQUEST` via `comms/send.sh` asking the agent to save state / exit cleanly if the UI allows.
3. **Hard recovery (last resort):** kill only that session — `tmux kill-session -t <session>` — then run the same **new-session** start command as in steps 3–4. Warn the user that unsaved work in that pane may be lost.
4. If `opencode` is not on `PATH` in tmux, fix environment or use the same invocation the user documented in `AGENT.md` / spawn notes — then **ESCALATE** to the human with the exact error line.

---

## Principles

- **Apex does not write application code** — recovery is **ops**: tmux, paths, roster consistency.
- **Do not** spawn duplicate sessions: always `has-session` before `new-session`.
- **Do not** ACK-chase a dead session — fix the session first, then send messages.
- If the agent directory is missing from disk, this is not a tmux fix — **ESCALATE** (restore from git or re-run `/spawn-agent` scope with the user).
