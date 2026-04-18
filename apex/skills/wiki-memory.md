# /wiki-memory — When to consult Mnemosyne

**Mnemosyne** (`mnemosyne` session) owns the **Obsidian-style fleet vault** at **`../mnemosyne/memory/fleet-wiki/`**. Prism owns **`../prism/memory/shared.md`** (fast notice board). Use this skill so Apex does not confuse the two.

## Consult Mnemosyne (REQUEST) when
- The user or fleet needs a **durable, linked** record: ADRs, project lore, naming conventions, “how we work” across sessions.
- **`/spawn-agent`** adds a new peer — ask Mnemosyne to stub **`projects/<slug>/`** (or the agent name) in the vault and link it from **`00-MOC-Fleet.md`**.
- Work completes that should **graduate** from `shared.md` into structured notes (REQUEST ingestion + backlinks).
- Multiple projects risk **duplicate truth** — Mnemosyne consolidates and links.

## Use Prism / `shared.md` instead when
- Ephemeral **status**, quick FYI, or “today we learned” blurbs.
- Urgent broadcast everyone should see **this session** without vault churn.

## Usage pattern
```
/delegate mnemosyne "Ingest ADR: <title>. Link from fleet MOC and projects/<slug>/_index.md."
```

After delegation, tell the user you sent the wiki keeper (same visibility rules as other delegations).

## Recovery
Mnemosyne is in **`comms/roster.sh`** — **`ensure-fleet-up.sh`** starts it like other spawned agents (`opencode` in `../mnemosyne/`). If DOWN, **`/recover-agent mnemosyne`**.
