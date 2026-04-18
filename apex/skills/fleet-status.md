# /status

Check the status of all fleet agents.

## Usage
```
/status
```

## Behaviour
1. Run `tmux list-sessions` to check which agent sessions are alive.
2. For each agent in **`comms/roster.sh`** (forge, prism, optional peers like vikki, …):
   - Report whether the tmux session exists.
   - If it exists, capture the last few lines with `tmux capture-pane -t <session> -p | tail -5`.
3. Summarise fleet health: which agents are up, which are down.
4. If any agent is down, offer to restart it.
