# IMPROVEMENTS.md — Roadmap

Prioritized list of known gaps, from the 2026-07 audit. Fixed items are deleted, not checked off.

---

## 1. Backlog (prioritized)

### Reliability (fix on next touch of the service)

- **dovecot cert reload** (`nginx/default.nix:76`, also `mail-monitor/default.nix:22`): `reloadServices` includes `"dovecot2.service"` — unit is `dovecot.service`. ACME renewals never reload dovecot → stale certs until manual restart.
- **gotify X-Forwarded-Proto** (`gotify/default.nix:17`): hardcoded `http` on a forceSSL vhost — gotify thinks everything is plain HTTP. Drop the line; `recommendedProxySettings` already sets `$scheme`.
- **drop `bindsTo nginx`** on vaultwarden (`vaultwarden/default.nix:53`) and open-webui (`openwebui/default.nix:47`) — nginx restart/crash kills your password manager. Use `after` + `wants` only.
- **pin dawarich and gotify to loopback** — they listen on `0.0.0.0` while nginx proxies to 127.0.0.1. Defense in depth. (prometheus/blackbox/headscale already done.)
- **quarterly restore drill** — manual test-restore of restic backups to `/tmp/restore-test/` (see `hosts/beaver/system/services/backups/RUNBOOK.md`).

### Monitoring / alerts

- **`mkThresholdAlert` helper** in `alerts.nix` — 13 rules × ~55 lines of identical boilerplate → ~150 lines with a helper. Reduces chance of annotation/unit mismatches.
- **anubis metrics** on `127.0.0.1:9090` not scraped by prometheus.

### Code quality

- **parrot nvidia contradiction**: GPU env vars force `GBM_BACKEND=nvidia_drm`/`__GLX_VENDOR_LIBRARY_NAME=nvidia` while `videoDrivers` excludes nvidia. Pick one.
- **yubikey**: `pam.yubico.debug = true` left on; `security.rtkit.enable` misplaced (belongs in pipewire config); udev rule hardcodes user path.
- **brightness**: `sudo chmod a+rw /sys/class/backlight/amdgpu_bl1/brightness` in autostart — delete, use `brightnessctl` (already installed).

### Architecture / DRY

- **gecko parameterization**: `geckoNixos{1..4}.nix` are near-identical copies differing by hostname/IP/hardware. Collapse to one function with a per-host attrset.
- **cli-core/cli-wayland split**: `home/cli` mixes wayland-only packages with cross-platform tools. Split into `cli-core` (imported everywhere) and `cli-wayland` (desktops only).
- **162MB `assets/` in git**: wallpapers and screenshots. Move to a separate repository or fetch at activation.
- **nginx vhosts** for `justalternate.com` and `loicw.com` are byte-identical — generate from a list.

### CI

- **`nix flake check` evaluates but never builds.** Endgame: CI builds `beaverNixos` toplevel on push to main and pushes closures to `justalternate-nixcfg.cachix.org`. Hosts pull instead of compiling.
