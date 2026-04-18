# Fleet systemd + watchdog (when the user asks)

Use this when the user wants the fleet to **survive reboots**, **start on boot**, or **recover without manual tmux babysitting**. The repo ships **no** unit files on purpose — you generate them **for the OS actually running**.

## Before you write anything

1. **Detect the OS and init system** — do not assume Linux+systemd.

   ```bash
   uname -s
   test -d /run/systemd/system && echo systemd-present || echo no-systemd
   ```

   Read **`/etc/os-release`** when on Linux (ID, VERSION_ID) to tune paths and packaging notes.

2. **Confirm fleet root** — the directory containing **`start.sh`** (user may have cloned to `~/fleet` or elsewhere). **WorkingDirectory** and **ExecStart** must use **absolute paths**.

3. **Confirm user vs system service**
   - **User service** (`~/.config/systemd/user/`) — good when the fleet runs as a login user, no root.
   - **System service** (`/etc/systemd/system/`) — needs root; use when the machine is a dedicated box and ops want global enable.

Ask which they prefer if unclear.

---

## Linux + systemd (typical)

**Goal:** a **`.service`** unit that runs **`start.sh`** after network is up, and **restarts** if the process exits (simple “watchdog”: systemd’s **Restart=** — no need for `Type=notify` unless they ask for deep integration).

### Outline (adapt paths and user)

- **`[Unit]`** — `Description=`, `After=network-online.target` (optional `Wants=`).

- **`[Service]`** — **`start.sh` exits after launching tmux**, so a naive `Type=simple` unit may look “dead” right away. Pick one approach and explain it to the user:
  - **Pattern A — Boot once:** `Type=oneshot`, `RemainAfterExit=yes`, `ExecStart=/absolute/path/to/start.sh`. Good for “bring the fleet up after reboot.” Pair with a **systemd timer** (e.g. every few minutes) that runs a tiny script: if `./status.sh` says Apex is DOWN, run `start.sh` again — that’s your **lightweight watchdog**.
  - **Pattern B — Hold the unit “up”:** `ExecStart=/bin/bash -lc 'cd /absolute/path/to/fleet && ./start.sh && exec tail -f /dev/null'` (or `sleep infinity`) so the service stays active; add **`Restart=always`** if the shell dies. Crude but easy.
  - **Pattern C — Match what `start.sh` does** — duplicate its tmux `new-session` lines in `ExecStart=` only if the user wants tight control (harder to maintain).

Prefer **A + timer** for clarity; use **B** if they want a single unit and don’t care about philosophy.

- **`User=`** / **`Group=`** — match the login that owns the clone (avoid root unless required).

- **`Environment=`** or **`EnvironmentFile=`** — if `.env` must load, either **`EnvironmentFile=/path/to/fleet/.env`** (no secrets in unit file) or ensure `start.sh` sources it (it already does).

- **`WorkingDirectory=`** — fleet root.

### Enable (user example)

```bash
systemctl --user daemon-reload
systemctl --user enable --now opencode-fleet-lite.service
```

### Enable (system example)

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now opencode-fleet-lite.service
```

### Logs

```bash
journalctl --user -u opencode-fleet-lite.service -f
# or
sudo journalctl -u opencode-fleet-lite.service -f
```

---

## macOS (no systemd)

Use **launchd** — **`~/Library/LaunchAgents/`** plist. Same ideas: **WorkingDirectory**, **ProgramArguments** pointing at **`start.sh`** or `/bin/bash` with `-lc`, **`RunAtLoad`**, **`KeepAlive`**. Paths and labels differ; **do not** emit a Linux unit file.

---

## *BSD / other Unix

No systemd by default — **`rc.d`**, **OpenRC**, etc. Give **high-level** guidance or a minimal script the user’s OS expects; don’t pretend systemd.

---

## After you ship

- Show the **exact** unit/plist contents and **enable** commands.
- Tell the user how to **rollback** (`systemctl disable`, `rm` unit, `daemon-reload`).
- Remind them **secrets stay in `.env`**, not committed.

---

## Name

User may say “systemd”, “watchdog”, “start on boot”, “don’t die on reboot” — treat as the same intent unless they specify launchd or Windows.
