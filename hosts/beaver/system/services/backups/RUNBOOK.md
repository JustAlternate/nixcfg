# Backup Runbook — beaver

Restic snapshots to a Hetzner Storage Box via SFTP (password auth).

## Architecture

```
beaver                                     Hetzner Storage Box (hel1)
┌──────────────────────────────┐           ┌──────────────────────┐
│ postgresqlBackup  (daily and │           │ u641107.your-        │
│   before each Restic run)    │           │                      │
│   └─ dawarich → /var/backup/ │  sftp:23  │   storagebox.de:23   │
│                 postgresql/  │──────────▶│   /backups/beaver/   │
│                              │           │                      │
│ restic-backups-beaver (after)│   sshpass │                      │
│   /var/lib/bitwarden_rs      │   + ssh   │                      │
│   /var/vmail                 │─────*────▶│   encrypted snapshots│
│   /var/dkim                  │           │                      │
│   /var/www                   │           └──────────────────────┘
│   /var/lib/headscale         │
│   /var/lib/dawarich          │
│   /var/lib/rauthy            │
│   /var/lib/grafana           │
│   /var/lib/postgresql        │
│   /var/backup/postgresql     │
│   /var/lib/acme              │
│   /var/lib/tailscale         │
│   /var/lib/private/goatcounter│
│   /var/lib/private/gotify-server│
│   Open WebUI, PolyNovel,     │
│   OpenCode, nixcfg, keys     │
│   /var/backup/sqlite         │
└──────────────────────────────┘
```

## Schedule & Retention

| Event         | Schedule           | Retention                     |
|---------------|--------------------|-------------------------------|
| PG dumps      | daily @ 00:00 and before Restic | Latest and previous |
| SQLite copies | before each Restic run | Latest local copy        |
| Restic backup | Mon, Thu @ ~03:00  | 7 daily, 4 weekly, 6 monthly |
| Restic check  | after each backup  | `--read-data-subset=1%`       |
| Integrity test| manual (quarterly) | See "Integrity test" below    |

The `archive-moon` tag preserves the separate `/var/www/justalternate.com/moon`
snapshot indefinitely. Snapshot `92622200` contains the archived moon page and
video; restore it by snapshot ID if needed.

Restic saves Open WebUI data (including uploads and the vector index), PolyNovel,
OpenCode settings and history, the Nix configuration, SOPS age key and SSH host
keys. Open WebUI's model caches and OpenCode's installed dependencies are omitted.
Backups are encrypted, but the local SQLite copies under `/var/backup/sqlite` are
plaintext application data and are readable only by root.

The Restic password, Storage Box credentials, and SOPS age key must also be stored
somewhere accessible independently of Beaver and its Vaultwarden. A copy inside
the Restic repository cannot unlock that same repository.

## SQLite recovery

Each backup run creates and checks online SQLite copies before invoking Restic.
Restore the files under `/var/backup/sqlite` from the desired snapshot and use
them instead of the live database files captured separately:

| Copy | Destination |
|------|-------------|
| `vaultwarden.db` | `/var/lib/bitwarden_rs/db.sqlite3` |
| `headscale.db` | `/var/lib/headscale/db.sqlite` |
| `goatcounter.db` | `/var/lib/private/goatcounter/goatcounter-data/db.sqlite3` |
| `gotify.db` | `/var/lib/private/gotify-server/data/gotify.db` |
| `grafana.db` | `/var/lib/grafana/data/grafana.db` |
| `open-webui.db` | `/var/lib/private/open-webui/data/webui.db` |
| `open-webui-chroma.db` | `/var/lib/private/open-webui/data/vector_db/chroma.sqlite3` |
| `opencode.db` | `/root/.local/share/opencode/opencode.db` |

Stop the affected service before replacing its database, remove stale `-wal` and
`-shm` files, and restore the destination's ownership and permissions. Open
WebUI's uploads and vector index files are copied while the service is running;
they are not an atomic snapshot with its databases, so test recovery and rebuild
the index if necessary.

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
