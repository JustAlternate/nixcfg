# IMPROVEMENTS.md — Roadmap

Prioritized list of known gaps, from the 2026-07 audit. Check items off when they land.

---

## 1. Backups (highest priority) — in progress

**There are zero backups on beaver.** Every stateful service is one disk failure away from permanent data loss:
vaultwarden (passwords), `/var/vmail` (email), dawarich (GPS history), Keycloak + shared postgres,
headscale DB (tailnet control plane), grafana, goatcounter sqlite, `/var/www` (web roots).

**Plan:** restic with a sops-managed repository password. Target: Hetzner Storage Box (same DC, native SFTP, ~€3/month).
Alternative: Backblaze B2. Do not self-host the backup target (tailscale to a home machine — home uptime ≠ server resilience).

**Coverage:** `services.postgresqlBackup` dumps for all databases, `/var/vmail`, `/var/lib/bitwarden_rs`,
`/var/lib/headscale`, `/var/lib/dawarich`, `/var/lib/grafana`, goatcounter sqlite, `/var/www`, `/var/dkim`,
`/var/lib/acme`, `/var/lib/tailscale`.

**Schedule:** daily + `restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6`.

**Monitoring:** Prometheus alert if last backup age > 26h. A backup never restored is a rumor — quarterly restore drill to `/tmp/restore-test/`.

**Pre-rebuild tasks:**
- `tofu apply` in `~/iac/hetzner/` to provision the Storage Box (needs Hetzner API token — on swordfish)
- Add `RESTIC/PASSWORD` and `RESTIC/SFTP_USER` to sops after Storage Box exists

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
- **pin prometheus/blackbox/keycloak/gotify/headscale/dawarich to loopback** — they listen on `0.0.0.0` while nginx proxies to 127.0.0.1. Defense in depth.
- **loki disk headroom**: after retention kicks in, verify `/var/lib/loki` shrinks. If not, manual compaction or delete old chunks.

### Monitoring / alerts

- **alert bugs:**
  - Inode alert can never fire (0–1 fraction vs `gt 90` threshold) — needs `× 100` or `gt 0.9`.
  - `/var` filesystem alert is permanently NO_DATA (beaver has single `/`).
  - One annotation claims "20 errors/s" while the query threshold is `> 10`.
- **`mkThresholdAlert` helper** in `alerts.nix` — 13 rules × ~55 lines of identical boilerplate → ~150 lines with a helper. Eliminates the bugs above by construction.
- **alloy.river:20** drops any journal line containing `open(` — masks real "permission denied" errors. Narrow the drop rule.
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

### Docs

- **README.md**: firewall diagram says UFW (it's nixos nftables); lists ports 9111 and mail 587 (neither exist on the real system); sops key path is `/nix/sops/age/keys.txt` but the module reads `/root/.config/sops/age/keys.txt`. Sync with reality.
