# AGENTS.md - nixcfg Project

NixOS multi-machine configuration managed with flakes and Home Manager.

## 📁 Project Structure

```
flake.nix          # Entry point for all configurations
├─ hosts/          # Machine-specific configurations
│  ├─ beaver/      # VPS (Hetzner, aarch64-linux)
│  ├─ swordfish/   # Desktop (NixOS, x86_64-linux)
│  ├─ parrot/      # Laptop (NixOS, x86_64-linux)
│  ├─ owl/         # Mac M1 (nix-darwin, aarch64-darwin)
│  └─ gecko/       # Raspberry Pi (aarch64-linux)
├─ home/           # Shared home configurations
│  ├─ shell/       # Zsh config, AGENTS.md, dev tools
│  ├─ desktop/     # Hyprland, Waybar, etc.
│  ├─ dev/         # Development tools
│  └─ packages/    # Package sets
├─ nixos/          # Shared NixOS modules
│  ├─ core/        # Core system config
│  └─ desktop/     # Desktop environment
├─ modules/        # Shared modules (git, ssh, sops)
└─ secrets/        # SOPS-encrypted secrets
```

## ⚡ Build Commands

```bash
# Rebuild system (run from ~/nixcfg)
sudo nixos-rebuild switch --flake .#<hostname>

# Dry-run to preview changes
sudo nixos-rebuild dry-activate --flake .#<hostname>

# Check flake syntax
nix flake check

# Format nix files
nixfmt-rfc-style *.nix

# Update specific machines
sudo nixos-rebuild switch --flake .#beaverNixos
```

## 🔐 Secrets Management (SOPS-Nix)

- Encrypted with **age**, key derived from SSH key
- Key location: `~/.config/sops/age/keys.txt`
- Secrets file: `secrets/secrets.yaml`

### Adding a new secret
1. Add reference in `sops.nix`
2. Reference in nix config via `config.sops.secrets.<name>.path`
3. User enters the secret interactively: `sops secrets/secrets.yaml`

## 🌍 Environment Variables

- Location: `~/env-var/.env`
- Auto-loaded in Zsh via `~/.config/zsh/init.zsh`
- Contains API keys for LLMs, cloud services, etc.

## 🔍 Finding NixOS Options & Packages

**ALWAYS** use `nixos option` to verify option names and types before editing configs.

### Finding NixOS module options
```bash
# Get details for a specific option (non-interactive)
nixos option services.openssh.ports -n -f '/root/nixcfg#beaverNixos'

# Search for options matching a pattern (TUI)
nixos option services.fail2ban -f '/root/nixcfg#beaverNixos'

# Machine-specific flake refs:
#   beaver:    /root/nixcfg#beaverNixos
#   swordfish: /root/nixcfg#swordfishNixos
#   parrot:    /root/nixcfg#parrotNixos
```

### Finding available packages
```bash
# Search for a package in nixpkgs
nix search nixpkgs#<package-name>

# Get package info
nix eval nixpkgs#<package-name>.meta.description
```

### Rules
1. **NEVER** guess NixOS option names — always verify with `nixos option -f '/root/nixcfg#<configName>'`
2. **NEVER** assume package names exist — always verify with `nix search`
3. Check the option **type** before setting values (string vs list vs attrset)
4. Module-level options (e.g. `services.openssh.ports`) differ from `settings.*` keys (which map to sshd_config directives)
4. Module-level options (e.g. `services.openssh.ports`) differ from `settings.*` keys (which map to sshd_config directives)
