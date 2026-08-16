# IMPROVEMENTS.md — Roadmap

Prioritized list of known gaps, from the 2026-07 audit. Check items off when they land.

---

## 1. Backups (highest priority) — done

Backups are live via restic to Hetzner Storage Box (SFTP, `u641107.your-storagebox.de:23`).

**Landed config:**
- restic daily → 2×/week (Mon, Thu 03:00), randomized 2h delay
- `services.postgresqlBackup`: dawarich dumps before restic runs
- Prune: `--keep-daily 7 --keep-weekly 4 --keep-monthly 6`
- Check: `--read-data-subset=1%` after each backup
- Monitoring: Prometheus alert if last backup > 96h
- Auth: `RESTIC/SFTP_PASSWORD` via `SSHPASS` env (sshpass), host key pinned in `/etc/ssh/ssh_known_hosts`
- Docs: README.md entry + `hosts/beaver/system/services/backups/RUNBOOK.md`

**Still manual:** quarterly restore drill to `/tmp/restore-test/`.

---

## 2. Kill `~/env-var` plaintext API keys — beaver done, 3 hosts remain

`modules/home/zsh.nix` auto-loads plaintext API keys from `~/env-var/.env` into every shell, on every machine.
The project AGENTS.md rule 5 ("ALWAYS use sops, never plain text") is violated by the repo itself.

The `~/env-var/.env` mechanism itself is valid for non-sensitive tool config — it provides env vars to **all** machines.
The issue is API keys (MISTRAL_API_KEY, OPENROUTER_API_KEY) stored in plaintext there.

**Per-machine migration plan:**
- [x] **beaver:** `zsh.envVar.enable = false`. API keys via sops template (`hosts/beaver/system/vibe-env.nix` → `/root/.vibe/.env`).
- [ ] **swordfish:** disable env-var, add sops template for API keys
- [ ] **parrot:** disable env-var, add sops template for API keys
- [ ] **owl:** disable env-var, add sops template for API keys (nix-darwin, sops works differently)

Also done:
- Broken `sops.templates."vibe-env"` in `home/shell/llm.nix` cleaned up.
- AGENTS.md docs updated with the env-var/sops split.

---

## 3. Backlog (prioritized)

### Reliability (fix on next touch of the service)

- **dovecot cert reload** (`nginx/default.nix:35`): `reloadServices` includes `"dovecot2.service"` — unit is `dovecot.service`. ACME renewals never reload dovecot → stale certs until manual restart.
- **gotify X-Forwarded-Proto** (`gotify/default.nix:17`): hardcoded `http` on a forceSSL vhost — gotify thinks everything is plain HTTP. Drop the line; `recommendedProxySettings` already sets `$scheme`.
- **drop `bindsTo nginx`** on vaultwarden and open-webui — nginx restart/crash kills your password manager. Use `after` + `wants` only.
- **pin dawarich and gotify to loopback** — they listen on `0.0.0.0` while nginx proxies to 127.0.0.1. Defense in depth. (prometheus/blackbox/headscale already done.)
- **loki disk headroom**: after retention kicks in, verify `/var/lib/loki` shrinks. If not, manual compaction or delete old chunks.

### Monitoring / alerts

- **`mkThresholdAlert` helper** in `alerts.nix` — 13 rules × ~55 lines of identical boilerplate → ~150 lines with a helper. Reduces chance of annotation/unit mismatches.
- **anubis metrics** on `127.0.0.1:9090` not scraped by prometheus.

### Code quality

- **bridge `edit_file`** uses `grep -q '<old_string>'` (regex) and `${VAR/pat/rep}` (glob) — corrupts on `[`, `*`, `?` in source. Rewrite with literal string operations or use Go-native file manipulation instead of shell.
- **parrot nvidia contradiction**: GPU env vars force `GBM_BACKEND=nvidia_drm`/`__GLX_VENDOR_LIBRARY_NAME=nvidia` while `videoDrivers` excludes nvidia. Pick one.
- **yubikey**: `pam.yubico.debug = true` left on; `security.rtkit.enable` misplaced (belongs in pipewire config); udev rule hardcodes user path.
- **brightness**: `sudo chmod a+rw /sys/class/backlight/amdgpu_bl1/brightness` in autostart — delete, use `brightnessctl` (already installed).

### Architecture / DRY

- **gecko parameterization**: `geckoNixos{1..4}.nix` are near-identical copies differing by hostname/IP/hardware. Collapse to one function with a per-host attrset.
- **cli-core/cli-wayland split**: `home/cli` mixes wayland-only packages with cross-platform tools. owl's home file hand-copies ~35 packages to avoid them. Split into `cli-core` (imported everywhere) and `cli-wayland` (desktops only). Fixes owl drift.
- **162MB `assets/` in git**: wallpapers and screenshots. Move to a separate repository or fetch at activation.
- **nginx vhosts** for `justalternate.com` and `loicw.com` are byte-identical — generate from a list.

### CI

- **`nix flake check` evaluates but never builds.** Endgame: CI builds `beaverNixos` toplevel on push to main and pushes closures to `justalternate-nixcfg.cachix.org`. Hosts pull instead of compiling.
