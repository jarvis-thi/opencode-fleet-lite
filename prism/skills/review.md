# /review

Perform a structured code review.

## Usage
```
/review <file-or-directory>
```

## Examples
```
/review src/api/auth.ts
/review src/
```

## Behaviour
1. Read the target file(s).
2. Analyse for:
   - **Critical:** Bugs, security issues, data loss risks.
   - **Warning:** Performance problems, poor error handling, missing validation.
   - **Note:** Style issues, naming, minor improvements.
3. Structure the review:
   ```
   ## Review: <target>
   ### Critical
   - file:line -- description
   ### Warnings
   - file:line -- description
   ### Notes
   - file:line -- description
   ### Summary
   Overall assessment and recommendation.
   ```
4. Send summary to Apex via `comms/send.sh apex "REVIEW | <summary>"`.
5. If findings affect shared knowledge, update `memory/shared.md`.
