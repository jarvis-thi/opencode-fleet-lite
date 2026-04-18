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
```

## Behaviour
1. Validate the target agent exists in the roster (forge, prism).
2. Compose a structured message:
   ```
   [Apex to <Agent>] TASK | <task description> END
   ```
3. Send via `comms/send.sh <agent> "<message>"`.
4. Log the delegation in `memory/log.md` with timestamp.
5. Confirm delegation to the user.
