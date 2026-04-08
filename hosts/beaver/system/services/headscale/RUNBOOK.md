# Headscale & Tailscale Runbook

Control server: `https://headscale.justalternate.com`
User/tailnet: `gecko`
Hosted on: beaver (`nixos-beaver-8gb-nbg1-3`)

## Add a new NixOS node

1. Import the tailscale module in the host config:
   ```nix
   imports = [ ../../../modules/tailscale.nix ... ];
   ```
2. Rebuild: `sudo nixos-rebuild switch --flake .#<hostname>`
3. Approve on headscale (see below)

## Add a non-NixOS node

1. Install Tailscale:
   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   ```
2. Connect:
   ```bash
   tailscale up --login-server=https://headscale.justalternate.com --authkey=<PREAUTH_KEY>
   ```

## Set up an exit node

1. Enable IP forwarding on the machine:
   - **NixOS**: set `services.tailscale.advertiseExitNode = true;` (module handles the rest)
   - **Manual/Armbian**:
     ```bash
     echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/99-tailscale.conf
     echo 'net.ipv6.conf.all.forwarding = 1' >> /etc/sysctl.d/99-tailscale.conf
     sysctl -p /etc/sysctl.d/99-tailscale.conf
     tailscale up --login-server=https://headscale.justalternate.com \
       --authkey=<PREAUTH_KEY> --reset --advertise-exit-node
     ```
2. Approve exit node routes on beaver:
   ```bash
   # Find the node ID
   headscale nodes list
   # Approve exit routes
   headscale nodes approve-routes -i <ID> -r 0.0.0.0/0,::/0
   ```
3. On the client device, select the exit node in the Tailscale app

## Headscale admin commands (run on beaver)

```bash
headscale nodes list                              # List all nodes
headscale nodes list-routes -i <ID>               # Check node routes
headscale nodes approve-routes -i <ID> -r <routes># Approve routes
headscale nodes rename -i <ID> <name>             # Rename a node
headscale nodes delete -i <ID>                    # Remove a node
headscale nodes expire -i <ID>                    # Force re-auth
headscale preauthkeys list                        # List auth keys
headscale preauthkeys create                      # Create auth key
```

## Secrets

- Preauth key stored in SOPS: `secrets/secrets.yaml` under `HEADSCALE/PREAUTH_KEY`
- Decrypt: `sops -d secrets/secrets.yaml | grep PREAUTH`
