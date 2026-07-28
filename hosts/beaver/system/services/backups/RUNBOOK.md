# Backup Runbook — beaver

Restic daily snapshots to a Hetzner Storage Box via SFTP (password auth).

## Architecture

```
beaver                                     Hetzner Storage Box (hel1)
┌──────────────────────────────┐           ┌──────────────────────┐
│ postgresqlBackup  (daily)    │           │ u641107.your-        │
│   ├─ keycloak → /var/backup/ │  sftp:23  │   storagebox.de:23   │
│   └─ dawarich  →  postgresql/│──────────▶│   /backups/beaver/   │
│                              │           │                      │
│ restic-backups-beaver (after)│   sshpass │                      │
│   /var/lib/bitwarden_rs      │   + ssh   │                      │
│   /var/vmail                 │─────*────▶│   encrypted snapshots│
│   /var/dkim                  │           │                      │
│   /var/www                   │           └──────────────────────┘
│   /var/lib/headscale         │
│   /var/lib/dawarich          │
│   /var/lib/grafana           │
│   /var/lib/postgresql        │
│   /var/backup/postgresql     │
│   /var/lib/acme              │
│   /var/lib/tailscale         │
│   /var/lib/private/goatcounter│
│   /var/lib/private/gotify-server│
└──────────────────────────────┘
```

## Schedule & Retention

| Event         | Schedule           | Retention                     |
|---------------|--------------------|-------------------------------|
| PG dumps      | daily @ 00:00      | Latest only (overwritten)     |
| Restic backup | Mon, Thu @ ~03:00  | 7 daily, 4 weekly, 6 monthly |
| Restic check  | after each backup  | `--read-data-subset=1%`       |
| Integrity test| manual (quarterly) | See "Integrity test" below    |

## Files

- `default.nix` — NixOS module declaring the services, secrets, and timers
- Secrets: `RESTIC/PASSWORD`, `RESTIC/SFTP_USER`, `RESTIC/SFTP_PASSWORD` in `secrets/secrets.yaml`

## Check backup status

```bash
# Timer status
systemctl list-timers restic-backups-beaver.timer

# Last run
systemctl status restic-backups-beaver.service

# Full journal for today
journalctl -u restic-backups-beaver.service --since today --no-pager
```

## Manual backup

```bash
sudo systemctl start restic-backups-beaver.service
```

## List snapshots

```bash
source /run/restic-beaver-env
restic snapshots
```

## Integrity test (quarterly)

```bash
source /run/restic-beaver-env
restic check --read-data
```

## Recovery — full restore

Restore the entire repository to `/tmp/restore-beaver/`:

```bash
export RESTIC_CACHE_DIR=/tmp/restic-cache
source /run/restic-beaver-env
mkdir -p /tmp/restore-beaver
restic restore latest --target /tmp/restore-beaver
```

To restore to original locations (dangerous — review first):

```bash
restic restore latest --target /
```

## Recovery — restore a single file

```bash
source /run/restic-beaver-env
restic restore latest --target /tmp/restore-test --include /var/vmail
```
