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
