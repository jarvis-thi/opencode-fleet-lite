# /tune-fleet

Evolve **existing** agents into specialists — update `AGENT.md`, **skills**, and light “learn and improve” habits — without spawning a new node. Use whenever the user wants sharper roles, new playbooks, or feedback loops across the fleet.

## When to use

- User asks to make Forge / Prism / another agent **more of a specialist** (domain, tone, checks).
- User wants **new skills** (new `*.md` under an agent’s `skills/`).
- User wants **self-improvement** wiring: what to log after a task, when to update `prism/memory/shared.md`, periodic retros, etc.
- User references the README **Customization** section (“work with Apex to tune the fleet”).

## Principles

1. **Keep KISS** — skills are short markdown playbooks; avoid enterprise ceremony unless asked.
2. **Tell the user** what you will change before large edits; **ack fast**, then report files touched when done (same as **Keeping the user informed** in `AGENT.md`).
3. **Respect paths** — fleet root is the parent of `apex/`. Other agents live at `../forge/`, `../prism/`, `../<spawned>/`.

## Procedure

### 1. Clarify intent

- Which **agent(s)**? (forge, prism, apex, or a spawned name.)
- Specialist **focus**? (e.g. API hardening, research depth, release discipline.)
- **Self-improvement**: optional — e.g. “append lessons to `memory/log.md`”, “nudge Prism for `shared.md` after reviews”.

### 2. Read before write

- Target agent’s **`AGENT.md`** and existing **`skills/*.md`**.
- If changes affect cross-agent behavior, skim **`prism/memory/shared.md`** and the target’s **`memory/`** files.

### 3. Apply changes

- **Persona / rules:** edit `AGENT.md` (identity, voice, principles).
- **Capabilities:** add or edit files under **`skills/`** — one concern per file where possible; use clear headings and steps.
- **Learning loops:** encode habits inside a skill (e.g. “after each review, add a bullet to `memory/log.md` and offer a Prism REPORT for `shared.md`”) rather than vague advice.

### 4. Coordinate if needed

- If another agent must **adopt** a new convention, send them a short **INFO** or **REQUEST** via `comms/send.sh` so they load the new skill on next turn.

### 5. Close the loop

- Summarise for the **user**: what changed, which paths, how to invoke the new behavior (natural language or `/skill-name` if you added a slash-style title).
- Append a line to **`memory/log.md`** on Apex for significant fleet changes.

## Examples (user phrasing)

- “Make Forge obsess about tests — update its skills.”
- “Add a skill so Prism runs a quick security pass on every handoff from Forge.”
- “Set up a weekly retro: Apex reads `log.md` and proposes one fleet improvement.”

Execute with shell/file tools; do not hand the user a wall of instructions unless they asked for docs only.
