# AGENTS.md - Machine Context for AI Agents

## ⚠️ CRITICAL ENVIRONMENT CONSTRAINTS

### You Are Running on NixOS
- **NEVER** use global package managers: `apt`, `yum`, `pip install --user`, `npm install -g`, etc.
- **ALWAYS** check if packages are already installed before using `nix shell`
- **Nix is immutable**: Edit config files declaratively in `~/nixcfg`, then rebuild

### Nix Commands You Must Know
```bash
# Test a package temporarily
nix shell nixpkgs#<package> --command <command>

# Rebuild system after editing nixcfg
cd ~/nixcfg
sudo nixos-rebuild switch --flake .#<hostname>

# Update specific machine (beaver, swordfish, parrot)
sudo nixos-rebuild switch --flake .#beaverNixos

# Check configuration syntax
nix flake check

# Format nix files
nixfmt-rfc-style *.nix
```
## 🛠️ Available Tools & Languages

### Development Environment
Languages:        Go 1.23, Python 3.x, Java, JavaScript/TypeScript, Lua, C/C++
Version Managers: Go (nix-managed), Python (nix-managed)

## 📁 Project Structure & Workflows

### Primary Projects

#### 1. `~/nixcfg` - NixOS Configuration (Multi-Machine)
```
flake.nix          # Entry point for all configurations
├─ beaver/         # VPS (Hetzner) - self-hosted services
│  ├─ configuration.nix    # System config
│  ├─ home/               # Home Manager for root
│  └─ services/           # Custom services
├─ swordfish/      # Desktop (NixOS)
├─ parrot/         # Laptop (NixOS)
├─ owl/            # Mac M1 (nix-darwin)
└─ shared/         # Reusable modules
   ├─ shell/       # Zsh config & aliases
   ├─ desktop/     # Hyprland, Waybar, etc.
   └─ git.nix      # Git configuration

Common workflow:
cd ~/nixcfg
# Edit configuration in appropriate machine folder
# Rebuild
sudo nixos-rebuild switch --flake .#beaverNixos
```

#### 2. `~/iac` - Infrastructure as Code (Terraform/Opentofu)
```
├─ infra/
│  ├─ main.tf          # Hetzner Cloud infrastructure
│  ├─ variables.tf
│  └─ NixOS-install/   # Provisioning scripts
└─ nameserver/
   └─ main.tf          # DNS configuration

Workflow:
cd ~/iac/infra
opentofu plan
opentofu apply
```

## 🔐 Secrets Management

### SOPS-Nix Setup
```bash
# Secrets are encrypted with age
# Age key derived from SSH key: ~/.config/sops/age/keys.txt

# Adding new secret:
# 1. Add to sops.nix
# 2. Reference in nix config via config.sops.secrets.<name>.path
# 3. ask the user to enter the secret in interactive mode by himself with sops secrets/secrets.yaml 
```

### Environment Variables
- Location: `~/env-var/.env`
- Auto-loaded in Zsh via `~/.config/zsh/init.zsh`
- Contains API keys for LLMs, cloud services, etc.

## ⚡ Quick Reference Commands

### NixOS
```bash
# Full system rebuild
sudo nixos-rebuild switch --flake .#<hostname>

# Check what would change
sudo nixos-rebuild dry-activate --flake .#<hostname>
```

## 🏠 Machine Detection & Architecture

### Detecting Current Machine with `uname`
# Combined info
uname -a    # All system information

### Quick Detection Script
```bash
# Detect current machine type
ARCH=$(uname -m)
OS=$(uname -s)

if [ "$ARCH" = "x86_64" ] && [ "$OS" = "Linux" ]; then
    echo "x86_64-linux machine (swordfish or parrot)"
elif [ "$ARCH" = "aarch64" ] && [ "$OS" = "Linux" ]; then
    echo "aarch64-linux machine (beaver)"
elif [ "$ARCH" = "aarch64" ] && [ "$OS" = "Darwin" ]; then
    echo "aarch64-darwin machine (owl)"
else
    echo "Unknown architecture: $ARCH on $OS"
fi
```

### Architecture-Specific Notes
- **beaver** (aarch64-linux): ARM-based VPS, uses `systemArm` in flake, runs as root user
- **swordfish/parrot** (x86_64-linux): Standard x86_64 desktop/laptop, uses `system` in flake
- **owl** (aarch64-darwin): Apple Silicon Mac, uses `systemMac` in flake, nix-darwin config

### Why Architecture Matters
- Nix packages are architecture-specific
- `nix shell` commands must match the system architecture
- flake builds require correct system type
- Docker/podman containers may be architecture-specific

## 🚨 Important Warnings

1. **NEVER** use `sudo apt`, `pip install --user`, `npm install -g`
2. **ALWAYS** check existing packages before installing
3. **NEVER** commit secrets or keys
4. **ALWAYS** test nix config syntax before applying
6. **ALWAYS** use sops for secrets, never plain text
7. **NEVER** run long commands autonomously - ask user for confirmation
