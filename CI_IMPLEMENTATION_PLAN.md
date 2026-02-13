# nixcfg CI/CD Implementation Plan

**Date:** 2025-02-13  
**Status:** Final - Ready for Implementation  
**Target:** Beaver VPS (aarch64-linux) with 40GB Hetzner volume  

---

## Executive Summary

This plan implements a hybrid CI/CD pipeline for the nixcfg project:
- **Validation Jobs:** Run on GitHub-hosted runners (fast, free)
- **Build Jobs:** Run on self-hosted beaver (native aarch64)
- **Caching:** Cachix for built artifacts
- **Scope:** Build only beaver configuration (parrot/swordfish excluded for now)

---

## Prerequisites (COMPLETED)

- ✅ Cachix token added to `secrets/secrets.yaml` via SOPS
- ✅ GitHub token added to `secrets/secrets.yaml` via SOPS
- ✅ 40GB Hetzner volume attached to beaver as `/dev/sdb`

---

## PART 1: Volume Setup (Step 1)

### Current State
```
/dev/sdb: 40GB volume (unmounted, unformatted)
/dev/sda1: 75GB root (72% full, 21GB available)
```

### Action: Mount Volume for Runner

**Location:** `/var/lib/github-runner` (runner work directory)

**NixOS Configuration:**
```nix
# beaver/configuration.nix - Add to existing file

# Format and mount the 40GB Hetzner volume
fileSystems."/var/lib/github-runner" = {
  device = "/dev/sdb";
  fsType = "ext4";
  autoFormat = true;  # Will format if empty
  options = [ "defaults" "noatime" ];
};
```

**Benefits:**
- Isolates runner I/O from system disk
- 40GB dedicated space for builds (sufficient for beaver config)
- Easy to expand or replace volume in Hetzner console

---

## PART 2: GitHub Actions Runner Service (Step 2)

### Service Configuration

Add to `beaver/configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  # ... existing imports and configuration ...

  # ============================================
  # GitHub Actions Runner Configuration
  # ============================================
  
  # Read secrets from SOPS
  sops.secrets.github-runner-token = {
    sopsFile = ../secrets/secrets.yaml;
    key = "github_runner_token";
  };
  
  sops.secrets.cachix-auth-token = {
    sopsFile = ../secrets/secrets.yaml;
    key = "cachix_auth_token";
  };

  services.github-runners.beaver = {
    enable = true;
    name = "beaver-aarch64";
    url = "https://github.com/JustAlternate/nixcfg";
    tokenFile = config.sops.secrets.github-runner-token.path;
    
    # Use the mounted volume
    workDir = "/var/lib/github-runner";
    
    # Labels to target this runner
    extraLabels = [ "beaver" "aarch64-linux" "nixcfg" ];
    
    # Replace existing runner with same name
    replace = true;
    
    # Additional packages available to runner
    extraPackages = with pkgs; [
      git
      nix
      cachix
      sops
    ];
    
    # Environment variables
    extraEnvironment = {
      # Cachix auth token for pushing builds
      CACHIX_AUTH_TOKEN_FILE = config.sops.secrets.cachix-auth-token.path;
      # Ensure nix can find the flake
      NIX_PATH = "nixpkgs=${pkgs.path}";
    };
    
    # Service hardening (optional but recommended)
    serviceOverrides = {
      # Limit resources to prevent impacting services
      MemoryMax = "8G";
      CPUQuota = "80%";
      # Auto-restart on failure
      Restart = "always";
      RestartSec = "30";
    };
  };
  
  # Ensure directory exists and has correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/github-runner 0755 root root -"
  ];
}
```

### Service Features

| Feature | Implementation |
|---------|---------------|
| **Auto-start** | systemd service with `enable = true` |
| **Auto-restart** | `Restart = "always"` with 30s delay |
| **Secret management** | SOPS-nix for tokens |
| **Resource limits** | 8GB RAM max, 80% CPU quota |
| **Isolation** | Dedicated 40GB volume |
| **Updates** | GitHub runner auto-updates itself |

---

## PART 3: Cachix Cache Setup (Step 3)

### Cache Configuration

**Cache Name:** `justalternate-nixcfg` (or your chosen name)

**On each machine (parrot, swordfish, beaver, owl):**
```bash
# Add to system config:
# nix.settings.substituters = [ "https://justalternate-nixcfg.cachix.org" ];
# nix.settings.trusted-public-keys = [ "justalternate-nixcfg.cachix.org-1:..." ];
```

### What Gets Cached

- `beaverNixos` system closure
- All build dependencies
- Home Manager generation

---

## PART 4: GitHub Actions Workflow (Step 4)

### File: `.github/workflows/main.yml`

```yaml
name: nixcfg CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  # ==========================================
  # Job 1: Validation (GitHub-hosted)
  # ==========================================
  validate:
    name: Validate Configuration
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install Nix
        uses: cachix/install-nix-action@v25
        with:
          nix_path: nixpkgs=channel:nixos-unstable
          extra_nix_config: |
            experimental-features = nix-command flakes

      - name: Format Check (nixfmt)
        run: nixfmt . -c

      - name: Lint (statix)
        run: statix check . -i docker-compose.nix

      - name: Dead Code Detection (deadnix)
        run: deadnix . -f

      - name: SOPS Secrets Validation
        run: |
          nix run nixpkgs#sops -- --validate secrets/secrets.yaml

      - name: Flake Check
        run: nix flake check --impure

  # ==========================================
  # Job 2: Build Beaver (Self-hosted)
  # ==========================================
  build-beaver:
    name: Build Beaver Configuration
    needs: validate
    runs-on: [self-hosted, beaver]
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Cachix
        uses: cachix/cachix-action@v14
        with:
          name: justalternate-nixcfg
          authToken: ${{ secrets.CACHIX_AUTH_TOKEN }}

      - name: Build Beaver System
        run: |
          nix build .#nixosConfigurations.beaverNixos.config.system.build.toplevel \
            --out-link ./result-beaver
          
          echo "Build completed successfully"
          ls -la ./result-beaver

      - name: Push to Cachix
        run: |
          echo "Pushing beaver configuration to Cachix..."
          cachix push justalternate-nixcfg ./result-beaver
          
          # Also push the full closure
          nix store gc --dry-run 2>&1 | head -20 || true

      - name: Upload Build Artifact (Optional)
        uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: beaver-build-logs
          path: |
            ./result-beaver
            /var/lib/github-runner/_work/nixcfg/nixcfg/*.log
          retention-days: 7
```

### Workflow Diagram

```
Push to main / PR
       │
       ▼
┌──────────────────────────────┐
│ Job: validate                │
│ Runner: ubuntu-latest        │
│                              │
│ ├─ nixfmt . -c              │
│ ├─ statix check .           │
│ ├─ deadnix . -f             │
│ ├─ sops --validate          │
│ └─ nix flake check          │
└──────────────────────────────┘
       │
       │ (if success)
       ▼
┌──────────────────────────────┐
│ Job: build-beaver            │
│ Runner: self-hosted (beaver) │
│                              │
│ ├─ Setup Cachix             │
│ ├─ nix build .#beaverNixos  │
│ └─ cachix push ...          │
└──────────────────────────────┘
```

---

## PART 5: Pre-commit Hooks (Step 5)

### Implementation

Add to `flake.nix`:

```nix
{
  inputs = {
    # ... existing inputs ...
    
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, git-hooks, ... }@inputs:
    let
      # ... existing let block ...
    in
    {
      # ... existing nixosConfigurations and darwinConfigurations ...
      
      # ==========================================
      # Pre-commit Hooks (Cross-platform)
      # ==========================================
      checks = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" ] (system: {
        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt = {
              enable = true;
              entry = "${nixpkgs.legacyPackages.${system}.nixfmt-rfc-style}/bin/nixfmt -c";
            };
            statix = {
              enable = true;
              entry = "${nixpkgs.legacyPackages.${system}.statix}/bin/statix check";
              excludes = [ "docker-compose.nix" ];
            };
            deadnix = {
              enable = true;
              entry = "${nixpkgs.legacyPackages.${system}.deadnix}/bin/deadnix -f";
            };
          };
        };
      });

      # DevShell with hooks installed
      devShells = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" ] (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      });
    };
}
```

### Usage

**On all machines (parrot, swordfish, beaver, owl):**
```bash
# Enter devShell
nix develop

# Hooks auto-install and run on every commit

# Manual check
nix flake check
```

---

## Implementation Order (Step-by-Step)

### Phase 1: Volume Setup (5 minutes)
1. **Edit:** `beaver/configuration.nix`
   - Add filesystem mount for `/dev/sdb`
   - Save file

2. **Rebuild:**
   ```bash
   cd ~/nixcfg
   sudo nixos-rebuild switch --flake .#beaverNixos
   ```

3. **Verify:**
   ```bash
   df -h /var/lib/github-runner
   # Should show ~40GB available
   ```

### Phase 2: Secrets Verification (2 minutes)
1. **Verify secrets exist:**
   ```bash
   cd ~/nixcfg
   sops secrets/secrets.yaml
   # Check for:
   # - github_runner_token
   # - cachix_auth_token
   ```

2. **Exit without saving** (Ctrl+Q in sops)

### Phase 3: GitHub Runner Service (10 minutes)
1. **Edit:** `beaver/configuration.nix`
   - Add SOPS secrets imports
   - Add `services.github-runners.beaver` configuration
   - Save file

2. **Rebuild:**
   ```bash
   sudo nixos-rebuild switch --flake .#beaverNixos
   ```

3. **Verify service:**
   ```bash
   sudo systemctl status github-runner-beaver.service
   sudo journalctl -u github-runner-beaver -f
   ```

4. **Check GitHub UI:**
   - Go to: https://github.com/JustAlternate/nixcfg/settings/actions/runners
   - Should see "beaver-aarch64" as online

### Phase 4: Cachix Cache Setup (5 minutes)
1. **Create cache** (if not done):
   - Visit: https://cachix.org
   - Create cache: `justalternate-nixcfg`
   - Copy auth token

2. **Add to secrets.yaml** (already done per user)

3. **Subscribe beaver:**
   ```bash
   cachix use justalternate-nixcfg
   ```

### Phase 5: GitHub Actions Workflow (10 minutes)
1. **Edit:** `.github/workflows/main.yml`
   - Replace entire file with new workflow
   - Save

2. **Commit and push:**
   ```bash
   git add .github/workflows/main.yml
   git commit -m "ci: implement hybrid CI with self-hosted beaver runner"
   git push origin main
   ```

3. **Monitor:**
   - Go to: https://github.com/JustAlternate/nixcfg/actions
   - Watch workflow execute

### Phase 6: Pre-commit Hooks (10 minutes)
1. **Edit:** `flake.nix`
   - Add `git-hooks` input
   - Add `checks` and `devShells` outputs
   - Save

2. **Test locally on beaver:**
   ```bash
   nix develop
   # Try making a commit to test hooks
   ```

3. **Commit and push:**
   ```bash
   git add flake.nix flake.lock
   git commit -m "ci: add pre-commit hooks with nixfmt, statix, deadnix"
   git push origin main
   ```

### Phase 7: Test & Verify (10 minutes)
1. **Create test PR:**
   ```bash
   git checkout -b test/ci-pipeline
   # Make trivial change (add newline to README)
   git commit -m "test: verify CI pipeline"
   git push origin test/ci-pipeline
   ```

2. **Open PR** on GitHub

3. **Verify:**
   - Validation job runs on GitHub-hosted runner
   - Build job runs on beaver
   - Cachix receives the build

4. **Merge** if successful

---

## Verification Checklist

### Infrastructure
- [ ] Volume `/var/lib/github-runner` mounted with 40GB
- [ ] GitHub runner service running (`systemctl status`)
- [ ] Runner appears online in GitHub UI
- [ ] Cachix cache created and accessible

### Secrets
- [ ] `github_runner_token` in SOPS secrets.yaml
- [ ] `cachix_auth_token` in SOPS secrets.yaml
- [ ] Secrets accessible by runner service

### Workflow
- [ ] Validation job passes (format, lint, deadnix, sops, flake check)
- [ ] Build job runs on beaver
- [ ] Build completes successfully
- [ ] Push to Cachix succeeds

### Pre-commit Hooks
- [ ] `nix develop` works on beaver
- [ ] Hooks auto-install on entering shell
- [ ] Commit triggers hook validation

---

## Troubleshooting

### Runner Won't Start
```bash
# Check logs
sudo journalctl -u github-runner-beaver -n 100 --no-pager

# Verify secrets
sudo cat /run/secrets/github-runner-token

# Check permissions
ls -la /var/lib/github-runner
```

### Build Fails on Beaver
```bash
# Check disk space
df -h

# Check runner logs
sudo journalctl -u github-runner-beaver -f

# Manual test
nix build .#nixosConfigurations.beaverNixos.config.system.build.toplevel
```

### Cachix Push Fails
```bash
# Verify token
echo $CACHIX_AUTH_TOKEN_FILE
cat $CACHIX_AUTH_TOKEN_FILE

# Test manually
cachix push justalternate-nixcfg ./result-beaver
```

### Pre-commit Hooks Not Working
```bash
# Check hooks installed
ls -la .git/hooks/pre-commit

# Reinstall
rm .git/hooks/pre-commit
nix develop
```

---

## Maintenance

### Updating Runner
The runner auto-updates when GitHub releases new versions. If issues occur:
```bash
# Restart service
sudo systemctl restart github-runner-beaver

# Clear work directory (if corrupted)
sudo rm -rf /var/lib/github-runner/_work/*
sudo systemctl restart github-runner-beaver
```

### Volume Cleanup
```bash
# Check usage
du -sh /var/lib/github-runner/*

# Clean old builds
sudo rm -rf /var/lib/github-runner/_work/*/nixcfg/result-*

# Nix garbage collect
nix store gc
```

### Secret Rotation
```bash
# Update tokens in secrets.yaml
sops secrets/secrets.yaml

# Rebuild to pick up new secrets
sudo nixos-rebuild switch --flake .#beaverNixos

# Restart runner
sudo systemctl restart github-runner-beaver
```

---

## Future Enhancements (Optional)

1. **Build parrot/swordfish via remote builders**
   - Set up SSH from beaver to parrot/swordfish
   - Enable remote building

2. **Add gecko/owl builds**
   - If owl is online, add as runner for macOS builds
   - Cross-compile gecko configs

3. **Scheduled builds**
   - Weekly builds to catch upstream breakages
   - Flake update automation

4. **Build matrix**
   - Test multiple nixpkgs channels
   - Build with/without certain features

5. **Notifications**
   - Slack/Discord webhook on failures
   - Email notifications

---

## Summary

**What We're Building:**
- GitHub Actions runner on beaver using Hetzner's 40GB volume
- Hybrid CI: GitHub-hosted validation + self-hosted builds
- Cachix caching for faster rebuilds
- Pre-commit hooks for local validation

**Timeline:** ~50 minutes total (mostly waiting for builds)

**Outcome:**
- ✅ Automated validation on every push/PR
- ✅ Native aarch64 builds for beaver
- ✅ Shared binary cache for all machines
- ✅ Local pre-commit validation

---

**Ready to implement?** Start with Phase 1 (Volume Setup).
