# /report

Send a status report back to Apex.

## Usage
```
/report "<status message>"
```

## Examples
```
/report "API endpoints complete. 5 routes, all tested. Ready for review."
/report "Blocked on database schema -- need Prism's analysis first."
```

## Behaviour
1. Compose a structured message:
   ```
   [Forge to Apex] DONE | <status message> END
   ```
   Use DONE for completed tasks, BLOCKED for blockers, PROGRESS for updates.
2. Send via `comms/send.sh apex "<message>"`.
3. Log the report in `memory/log.md` with timestamp.
