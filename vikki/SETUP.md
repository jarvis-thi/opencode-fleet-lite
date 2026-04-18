# Vikki setup (optional wiki-memory agent)

Vikki is **optional**. The default fleet is **Apex + Forge + Prism**. If you want the wiki-memory agent, add Vikki to the roster so Apex will auto-start her and peers can message her.

## What Vikki provides

- Obsidian-style vault under `memory/fleet-wiki/` (MOC + `fleet/` + `projects/<slug>/`).
- Responds to REQUESTs to ingest findings, create project stubs, and keep durable linked truth.

## Enable Vikki (Apex procedure)

1. **Add Vikki to Apex’s roster** so `ensure-fleet-up.sh` will bring her up:

   - Edit `apex/comms/roster.sh` and add:
     - `[vikki]="vikki"`

2. **Update peer rosters** so Forge/Prism can message Vikki:

   - Edit `forge/comms/roster.sh` and add:
     - `[vikki]="vikki"`
   - Edit `prism/comms/roster.sh` and add:
     - `[vikki]="vikki"`

3. **Start (or let Apex auto-start):**

   - From repo root: `./start.sh` then `tmux attach -t apex`
   - After your next message to Apex, it runs `bash scripts/ensure-fleet-up.sh` and Vikki should appear as a tmux session:
     - `tmux attach -t vikki`

4. **Optional: announce to the fleet**

Send a one-line INFO to Forge/Prism that Vikki is now available for durable notes (Apex can do this via `comms/send.sh`).

## Disable Vikki

- Remove `[vikki]="vikki"` from the rosters above.
- Stop the session if it’s running: `tmux kill-session -t vikki`

