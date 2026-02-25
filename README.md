# nixcfg

This repository contains the declaration of my systems running [Nix/NixOS](https://nixos.org/)

- 🦫 beaver: My VPS running NixOS and selfhosting services.
- 🐟 swordfish: My Desktop running NixOS desktop. (login only through yubikey)
- 🦜 parrot: My Laptop running NixOS. (login only through yubikey)
- 🦉 owl: My arm processor Mac M1 running [nix-darwin](https://github.com/nix-darwin/nix-darwin).
- 🦎 gecko: My raspberry py configs (WIP)

### Features

#### VPS (beaver)
- Identity management : [keycloak](https://keycloak.org) (with SSO using github provider or yubikey)
- Reverse proxy & web server: [nginx](https://nginx.org/en/)
- Monitoring (observability) : [Grafana](https://github.com/grafana/grafana) (only accessible through Keycloak)
- Monitoring (metric collector): [Prometheus](https://github.com/prometheus/prometheus)
- Monitoring (logs aggregator): [Loki](https://github.com/grafana/loki)
- Monitoring (Alerts notification): [Gotify](https://github.com/gotify/server)
- Mail server: [Simple nixos mail server](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver)
- Password management: [Vaultwarden](https://github.com/dani-garcia/vaultwarden) (only accessible through Keycloak)
- LLM frontend : [openwebui](https://github.com/open-webui/open-webui) (only accessible through Keycloak)
- Sharing gps location service: [Dawarich](https://github.com/Freika/dawarich)
- CI/CD: **Self-hosted GitHub Actions Runner** (aarch64-linux) for building ARM64 NixOS configurations
- Security: sops-nix (secrets management), Fail2Ban (intrusion prevention)
- Binary cache: [Cachix](https://cachix.org) (`justalternate-nixcfg.cachix.org`)

##### Infrastructure Overview (Beaver VPS)

```mermaid
flowchart LR
    Me["🧑‍💼 Me"]
    subgraph Internet["🌐 Internet"]
        Users["Users"]
        GitHub["GitHub"]
        Cloudflare["Cloudflare<br/>(DNS)"]
    end

    subgraph Beaver["🖥️ Beaver VPS"]
        
        subgraph Network["🕸️ Network Layer"]
            Firewall["🔥 UFW Firewall<br/>TCP: 443, 8443, 9111<br/>Mail: 25, 465, 587, 993"]
            Nginx["🌐 Nginx<br/>Reverse Proxy + SSL"]
        end

        subgraph Security["🔒 Security Layer"]
            Sops["SOPS<br/>(Secrets Management)"]
        end

        subgraph Services["🚀 Self-Hosted Services"]
            Vaultwarden["Vaultwarden<br/>(Passwords)"]
            OpenWebUI["OpenWebUI<br/>(LLM Frontend)"]
            Mail["Simple NixOS Mail<br/>(Postfix/Dovecot)"]
            Dawarich["Dawarich<br/>(GPS Tracking)"]

            subgraph Monitoring["🔍 Monitoring"]
                Gotify["Gotify (Alerts notifier)"]
                BlackBox["BlackBox exporter"]
                Promtail["Promtail (Logs)"]
                Loki["Loki (Logs)"]
                Prometheus["Prometheus (Metrics)"]
                Grafana["Grafana<br/>"]
            end

            subgraph Auth["🔐 Identity Layer"]
                Keycloak["Keycloak SSO<br/>"]
            end
        end
    end

    %% External Traffic
    Users --> Cloudflare
    Cloudflare -->|"HTTPS (443)"| Firewall
    Users -->|"SSH (8443)"| Firewall

    %% Internal Routing
    Firewall -->|"Proxy"| Nginx

    %% Monitoring Flow
    BlackBox --> Prometheus
    Prometheus --> Grafana
    Promtail --> Loki
    Loki --> Grafana

    Sops -->|"Secret"| Grafana

    Keycloak -->|"OIDC"| Grafana

    Sops -->|"Secret"| Vaultwarden
    Sops -->|"Secret"| Mail
    Sops -->|"Secret"| Keycloak

    GitHub -->|"IdP"| Keycloak

    %% Auth Flow
    Keycloak -->|"OIDC"| OpenWebUI
    Keycloak -->|"OIDC"| Dawarich
    Keycloak -->|"OIDC"| Vaultwarden

    Sops -->|"Secret"| Dawarich

    Prometheus --> Gotify
    Gotify --> Me

```

#### Monitoring Dashboards :

##### Node exporter 

![./assets/node-exporter.png](./assets/node-exporter.png)

##### Logs

![./assets/logs.png](./assets/logs.png)

##### Status, Probe and TLS certificates

![./assets/blackbox.png](./assets/blackbox.png)

##### Alerting

![./assets/alerts.png](./assets/alerts.png)


#### Desktop (swordfish and parrot)
- DE: [Hyprland](https://hyprland.org/)
- Terminal: [Ghostty](https://ghostty.org/)
- Bar: [Waybar](https://github.com/Alexays/Waybar)
- File Manager: [yazi](https://yazi-rs.github.io/)
- Editor: Neovim [justnixvim](https://github.com/JustAlternate/justnixvim)
- Fetcher: [fastfetch](https://github.com/fastfetch-cli/fastfetch)
- Font: [nerdfonts](https://www.nerdfonts.com/)
- Launcher: [rofi](https://github.com/A417ya/rofi-wayland)
- Browser: [firefox](https://www.mozilla.org/en-US/firefox/)
- Discord: [Vesktop](https://github.com/Vencord/Vesktop)
- Emoji wheel: rofi + [bemoji](https://github.com/marty-oehme/bemoji)
- Music Visualizer: [cava](https://github.com/karlstav/cava)
- Secrets: [sops-nix](https://github.com/Mic92/sops-nix)
- Yubikey only login with automatic screen lock when not detected. 

### 🔐 Security & Access Management

Since this repository is fully public, I highly value using **security-by-design** principles, here are what I implemented and my general direction about security :

**Secrets Management (Git friendly)**
- **[SOPS-Nix](https://github.com/Mic92/sops-nix)**: All sensitive data (API keys, passwords, tokens) is encrypted via `age` using keys derived directly from SSH keys. To avoid plaintext secrets in version control.
- **[Vaultwarden](https://github.com/dani-garcia/vaultwarden)**: Self-hosted, encrypted credential management for personal and administrative access.

**Identity & Access Management (IAM) & Zero Trust**
- **Centralized IAM & IdP Architecture**: Deployed **Keycloak** to function as both a comprehensive IAM system and the primary Identity Provider (IdP). It enforces OpenID Connect (OIDC) across all my self-hosted services while unifying Single Sign-On (SSO) through GitHub OAuth and WebAuthn (YubiKey).
- **Passwordless Multi-Factor Authentication (MFA)**:
  - Full PAM U2F integration via **YubiKey** for passwordless host access.
  - Automatic screen locking upon YubiKey removal and hardware touch requirements.
  - *Architecture Note:* By relying heavily on physical hardware (**Possession factor**) and since I'm looking forward into also adding biometrics (**Inherence factor**), this infrastructure will soon achieves **2FA compliance without relying on vulnerable knowledge factors at all (passwords)**. 

**Network & Infrastructure Hardening**
- **Firewall**: allowing only ports 443, 8443, 25, 465, 587, 993. 
- **Automated Mitigation**: **Fail2Ban** Configured to monitor logs and automatically ban IPs that try to brute-force.
- **SSH Hardening**: Password authentication disabled. Access only using ssh key on non-standard port (8443).

## Installation

Enter a shell with git and vim.
```
nix-shell -p git vim
```

Clone the repository and enter it
```
git clone https://github.com/JustAlternate/nixcfg
cd nixcfg
```

Create your very own host folder
```
mkdir <myMachineName>
```

Create your hardware config
```
nixos-generate-config --show-hardware-config > <myMachineName>/hardware-configuration.nix
```

Modify your host configuration by importing different modules
```
vim <myMachineName>/configuration.nix
```

Modify the flake.nix to add your machine
```
vim flake.nix
```

Temporary activate flakes experimental features and rebuild switch
```
NIX_CONFIG="experimental-features = nix-command flakes"
sudo nixos-rebuild switch --flake .#<myMachineName>Nixos
```

## Advanced Install process (optional)

Create a `.ssh` folder and populate it with your ssh private key
```
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -C "email@email.com"
```

Create your sops age private key
```
sudo mkdir -p /nix/sops/age
sudo nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > /nix/sops/age/keys.txt"
```
