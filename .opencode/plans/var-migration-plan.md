# /var Migration Plan - NixOS Approach

## Overview
Migrate the entire `/var` directory from the 75GB root disk to the 40GB Hetzner volume using NixOS declarative configuration.

## Current State

### Disk Usage
- **Root disk (/dev/sda1):** 75GB, 49GB used (68%)
  - /nix/store: 34GB (keep on root disk)
  - /var: ~8.5GB (migrate to volume)
- **Volume (/dev/sdb):** 40GB, 325MB used (1%)
  - Currently mounted at `/var/lib/github-runner`

### Migration Strategy

Since /var already contains ~8.5GB of data and the volume currently has the runner data at `/var/lib/github-runner`, we need to:

1. Temporarily copy all /var data to a staging location
2. Unmount the volume from its current location
3. Mount the volume at /var
4. Copy data to the new mount
5. Update NixOS configuration to make it permanent

## Detailed Implementation Plan

### Phase 1: Pre-Migration Preparation (5 minutes)

#### 1.1 Verify Space Requirements
```bash
du -sh /var
df -h /dev/sdb
```

#### 1.2 Document Current Mounts
```bash
mount | grep sdb > /root/migration-logs/pre-migration-mounts.txt
```

### Phase 2: Service Shutdown (5 minutes)

Stop all services in reverse dependency order:
```bash
sudo systemctl stop github-runner-beaver.service
sudo systemctl stop openwebui.service opencloud.service vaultwarden.service
sudo systemctl stop dawarich-sidekiq-all.service dawarich-web.service
sudo systemctl stop grafana.service prometheus2.service loki.service
sudo systemctl stop rspamd.service
sudo systemctl stop postgresql.service redis-dawarich.service
sudo systemctl stop keycloak.service
sudo systemctl stop nginx.service
sudo systemctl stop acme-dns.service
sudo systemctl stop fail2ban.service
sudo podman stop --all
sudo systemctl stop podman.service
sudo sync
```

### Phase 3: Data Migration (15-25 minutes)

```bash
# Create staging and mount volume
sudo mkdir -p /mnt/var-staging
sudo umount /var/lib/github-runner
sudo mount /dev/sdb /mnt/var-staging

# Copy all /var data
sudo rsync -avHAX --progress --exclude="/var/run" --exclude="/var/lock" \
  /var/ /mnt/var-staging/ 2>&1 | tee /root/migration-logs/rsync-progress.log

# Verify copy
du -sh /var
du -sh /mnt/var-staging
```

### Phase 4: NixOS Configuration Update (10 minutes)

Update `/root/nixcfg/beaver/configuration.nix`:

**Remove:**
```nix
# REMOVE this block:
fileSystems."/var/lib/github-runner" = {
  device = "/dev/sdb";
  fsType = "ext4";
  autoFormat = true;
  options = [ "defaults" "noatime" ];
};
```

**Add:**
```nix
# Mount volume at /var
fileSystems."/var" = {
  device = "/dev/sdb";
  fsType = "ext4";
  options = [ "defaults" "noatime" ];
};

# Ensure directories exist
systemd.tmpfiles.rules = [
  "d /var/lib 0755 root root -"
  "d /var/log 0755 root root -"
  "d /var/cache 0755 root root -"
  "d /var/tmp 1777 root root -"
];
```

### Phase 5: Switchover (5 minutes)

```bash
# Unmount staging
sudo umount /mnt/var-staging

# Backup old /var
sudo mv /var /var.old-backup-$(date +%Y%m%d-%H%M%S)
sudo mkdir /var
sudo chmod 755 /var

# Apply NixOS configuration
cd /root/nixcfg
sudo nixos-rebuild switch --flake .#beaverNixos

# Verify mount
mount | grep "on /var"
df -h /var
```

### Phase 6: Service Restart (10-15 minutes)

```bash
# Fix permissions if needed
sudo chown -R postgres:postgres /var/lib/postgresql 2>/dev/null || true
sudo chown -R grafana:grafana /var/lib/grafana 2>/dev/null || true

# Start services
cd /root/nixcfg
sudo nixos-rebuild switch --flake .#beaverNixos

# Or manually:
sudo systemctl start postgresql redis-dawarich
sudo systemctl start keycloak vaultwarden
sudo systemctl start grafana prometheus2 loki
sudo systemctl start dawarich-web dawarich-sidekiq-all
sudo systemctl start openwebui opencloud
sudo systemctl start nginx acme-dns fail2ban
sudo systemctl start podman
sudo podman start --all
sudo systemctl restart github-runner-beaver
```

### Phase 7: Verification

```bash
# Check all services
sudo systemctl is-active postgresql keycloak grafana nginx
sudo systemctl --failed

# Check disk layout
df -h
mount | grep -E "(/var|sdb)"

# Test services
curl -s http://localhost:80
curl -s http://localhost:8080
ls -la /var/lib/postgresql/
```

### Phase 8: Commit Changes

```bash
cd /root/nixcfg
git add beaver/configuration.nix
git commit -m "feat(beaver): migrate /var to 40GB volume

Migrate entire /var directory from root disk to Hetzner volume:
- Move /var from /dev/sda1 (75GB) to /dev/sdb (40GB)
- Update fileSystems configuration
- Free up ~8.5GB on root disk (~35GB free after migration)"
git push origin main
```

### Phase 9: Cleanup (After 48 Hours)

```bash
# Remove backup (ONLY after 48h stability)
sudo rm -rf /var.old-backup-*
```

## Rollback

If migration fails:
```bash
sudo umount /var
sudo rmdir /var
sudo mv /var.old-backup-* /var
cd /root/nixcfg
git checkout beaver/configuration.nix.pre-migration-backup
sudo nixos-rebuild switch --flake .#beaverNixos
sudo reboot
```

## Timeline

- Preparation: 5 min
- Service shutdown: 5 min
- Data migration: 15-25 min
- Configuration: 10 min
- Switchover: 5 min
- Service restart: 10-15 min
- Verification: 10 min

**Total downtime: 30-50 minutes**

## Post-Migration

- Root disk: ~35GB free (was 23GB)
- Volume: ~31GB free
- All services data on dedicated volume
- Easy to backup /var independently
