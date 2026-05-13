# AGENTS.md - nixcfg Project

NixOS multi-machine configuration managed with flakes and Home Manager.

## 📁 Project Structure & Architecture

This project strictly separates system-level configuration (NixOS/nix-darwin) from user-level configuration (Home Manager), and heavily utilizes shared profiles and modules to keep hosts DRY (Don't Repeat Yourself).

### 🏗️ Directory Layout

- **`hosts/`**: The entry points for every machine.
  - `hosts/<hostname>/system/`: OS-level configuration (hardware, boot, networking).
  - `hosts/<hostname>/home/`: User-level configuration entry point (imports from `../../home/`).
- **`home/`**: Reusable **Home Manager** configurations, broken down by domain (`cli`, `desktop`, `dev`, `packages`, `shell`).
- **`profiles/`**: Reusable **System-level** configurations (e.g., `profiles/nixos/core`, `profiles/nixos/desktop`).
- **`modules/`**: Custom defined Nix options (using `lib.mkOption`).
  - `modules/nixos/`: System-level custom modules (e.g., tailscale, sops).
  - `modules/home/`: User-level custom modules.
- **`secrets/`**: SOPS encrypted YAML files.

### 📜 Imports & Architecture Rules of Thumb

When writing new Nix files or adding features, follow these rules strictly to respect the architecture:

1. **System vs. User Space:**
   - If it requires root, touches hardware, or is a system service (e.g., Docker, SSHd) → Put it in `profiles/` or `hosts/<hostname>/system/`.
   - If it is a user tool, dotfile, CLI utility, or user-specific IDE config → Put it in `home/` (e.g., `home/dev/`, `home/shell/`).

2. **Where to put new configuration:**
   - **Machine-specific:** Put it directly in `hosts/<hostname>/system/default.nix` or `hosts/<hostname>/home/default.nix`.
   - **Shared by multiple machines (System):** Create a new file in `profiles/nixos/` and import it in the respective hosts' system configurations.
   - **Shared by multiple machines (User):** Create a new file in `home/` (e.g., `home/dev/newtool.nix`) and import it in the respective hosts' home configurations.

3. **Modules vs. Profiles:**
   - Use **`profiles/`** or **`home/`** to bundle existing options together (e.g., installing a package and writing its config).
   - Use **`modules/`** ONLY when you need to declare entirely new Nix options (`options = { ... }`) that don't exist in standard nixpkgs or home-manager.

4. **Architecture Awareness:**
   - `x86_64-linux` (parrot, swordfish): Full desktop/laptop environments. Safe to import heavy graphical profiles.
   - `aarch64-linux` (beaver, gecko): Headless/server/SBC environments. Keep configs lightweight.
   - `aarch64-darwin` (owl): Mac environment. Avoid Linux-only systemd services or NixOS-specific hardware configs.

## ⚡ Build Commands

```bash
# Rebuild system (run from ~/nixcfg)
sudo nixos-rebuild switch --flake .#<hostname>

# Check flake syntax
nix flake check
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
