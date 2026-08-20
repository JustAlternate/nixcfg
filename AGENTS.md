# AGENTS.md - nixcfg Project

NixOS multi-machine configuration managed with flakes and Home Manager.

**Docs-sync rule:** when you change behavior that README.md, this file, or any RUNBOOK.md describes, update the docs in the same commit. Stale docs are worse than no docs.

## 📋 IMPROVEMENTS.md

`IMPROVEMENTS.md` is the living backlog of **user-approved** work items. Nothing goes in it without the user's agreement.

**When you fix an item:** delete its line entirely. No checkboxes, no strikethroughs — just remove it.

**When you spot something worth improving** during conversation, propose it to the user. If they agree, add a concise bullet under the appropriate section. If they decline, drop it.

**Do not read this file proactively.** Only consult it when the user explicitly asks you to work from it.

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

## 📦 Channel Policy (nixpkgs)

**Services on beaver get `pkgs.*` (stable).** No exceptions without a comment.

`pkgs.unstable.*` is allowed only for:
- Fast-moving leaf desktop tools where freshness matters.
- Services where stable's version is *older* than the currently-running version and downgrading would break stateful DB migrations — requires a `# pin reason: ...` comment on the line.

**`master` and personal forks: never.** They were deliberately removed from `flake.nix` inputs and overlays — do not re-add them.

Before changing any stateful service's channel: compare the running version (`systemctl cat <unit> | grep /nix/store`) against the target channel's version (`nix eval nixpkgs#<pkg>.version`). Rails and alembic migrations do not roll back.

## 🦫 Beaver Service Rules

**Loopback by default.** Bind services to `127.0.0.1`. nginx is the only public edge. Any `0.0.0.0` bind needs a justification comment.

**Hardening is mandatory for new systemd services.** Copy the template from `hosts/beaver/system/services/mail-monitor/default.nix`:
- `DynamicUser = true`
- `NoNewPrivileges = true`
- `ProtectSystem = "strict"`
- `ProtectHome = true`
- `PrivateTmp = true`
- `PrivateDevices = true`
- `CapabilityBoundingSet = ""`

If a service legitimately can't use one of these, document why with a comment (e.g. `cptr` is an interactive executor — it spawns shells, runs sudo, and needs the real filesystem, so most of the template is off; the security boundary is unprivileged user + loopback bind + SSO instead).

**NEVER expose an unauthenticated executor endpoint** (shell command, file write/edit) on any network interface. Loopback-only + auth, or don't build it.

**Secrets always via sops.** Only these mechanisms: `config.sops.secrets.<name>.path`, `environmentFile`, `sops.templates`, `$__file{}`. Never interpolate secrets into the nix store (store paths are world-readable). Never create plaintext env files.

**Stateful services.** When adding retention/limits: verify the *enforcement* flag, not just the limit value. Loki `retention_period` did nothing until `compactor.retention_enabled = true`. Alert thresholds must match expression units — a fraction 0–1 needs `gt 0.9`, not `gt 90`.

## ⚡ Build Commands

```bash
# Before every change (run from ~/nixcfg)
deadnix . -f && statix check .
nix flake check

# Rebuild beaver (mandatory dry-activate first)
sudo nixos-rebuild dry-activate --flake .#beaverNixos
# Then, with explicit user confirmation:
sudo nixos-rebuild switch --flake .#beaverNixos

# Rebuild desktops
sudo nixos-rebuild switch --flake .#<hostname>
```

## 🔐 Secrets Management (SOPS-Nix)

- Encrypted with **age**, key derived from SSH key
- Key location: `~/.config/sops/age/keys.txt`
- Secrets file: `secrets/secrets.yaml`

### Adding a new secret
1. Declare it in the right file:
   - Shared secret (all hosts, e.g. tailscale key) → `modules/nixos/sops.nix`
   - Beaver-only server secret → `hosts/beaver/system/secrets.nix`
2. Reference in nix config via `config.sops.secrets.<name>.path`
3. User enters the secret interactively: `sops secrets/secrets.yaml`

### Rules
- Always use `sops.templates` or `environmentFile` to inject secrets into services — never interpolate into store paths.
- `sops --encrypt` requires the input file path to match `.sops.yaml`'s `path_regex` (`secrets.yaml$`); copy the temp file to a `*-secrets.yaml` path before re-encrypting. Newly created nix files must be `git add`ed before `nix flake check`/`nix build` can see them.

## 🌍 Environment Variables

- `~/env-var/.env` is auto-loaded by zsh on all machines (non-sensitive tool config). Do not put API keys or secrets here — use sops for those.
- API keys (MISTRAL, OpenRouter) are provisioned via sops templates on a per-machine basis (e.g. `hosts/beaver/system/vibe-env.nix` renders `/root/.vibe/.env`).

## ✅ Before Every Rebuild on Beaver

Each step must pass before `switch`:

1. `deadnix . -f` — zero output means clean.
2. `statix check .` — no warnings introduced by the change.
3. `nix flake check` — all configurations evaluate.
4. `nixos-rebuild dry-activate --flake .#beaverNixos` — check which units restart, no errors.
5. Ask for explicit user confirmation before `switch`.

The dry-activate is mandatory: beaver is a production VPS running mail and password manager. Blast-radius matters.

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
