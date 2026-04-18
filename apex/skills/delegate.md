# /delegate

Delegate a task to a fleet agent.

## Usage
```
/delegate <agent> "<task description>"
```

## Examples
```
/delegate forge "Build a REST API for user management with CRUD endpoints"
/delegate prism "Review the auth module for security issues"
/delegate mnemosyne "Stub projects/acme/_index.md and link from 00-MOC-Fleet.md for the new client work."
```

## Behaviour
1. You should already have run **`bash scripts/ensure-fleet-up.sh`** this user turn (`AGENT.md`). Validate the target exists in **`comms/roster.sh`** (forge, prism, mnemosyne, …).
2. Compose a structured message:
   ```
   [Apex to <Agent>] REQUEST | <task description> END
   ```
3. Send via `comms/send.sh <agent> "<message>"`.
4. Log the delegation in `memory/log.md` with timestamp.
5. Confirm delegation to the user.
