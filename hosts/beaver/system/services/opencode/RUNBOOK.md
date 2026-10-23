# opencode server runbook

Root-privileged [opencode](https://github.com/sst/opencode) server so the user can
chat with an agent on beaver from their phone (OpenCode Mobile) over the tailnet.

## Connect

1. Phone: Tailscale connected to headscale.
2. OpenCode Mobile → add server:
   - URL: `http://100.64.0.3:4096` (beaver's tailnet IPv4; if it ever changes,
     run `tailscale ip -4` on beaver)
   - Username: `opencode`
   - Password: `sudo sops -d --extract '["OPENCODE"]["SERVER_PASSWORD"]' /root/nixcfg/secrets/secrets.yaml`
   - Directory: leave empty (uses `/root/agent`)
3. Send a message. The agent auto-approves tools and can act as root anywhere on
   the host.

## Layout

- `/root/agent` — server cwd. Managed by `hosts/beaver/home/agent.nix`.
  - `AGENTS.md` — host briefing, safety rules, phone-chat style.
  - `opencode.json` — `permission: allow` (incl. `external_directory`), sharing
    disabled, no autoupdate.
- `/root/.config/opencode/opencode.jsonc` — global model/agent config (unmanaged).
- `/root/.local/share/opencode` — sessions and auth.
- `/run/secrets/opencode-env` — Basic auth + `OPENROUTER_API_KEY`, rendered by
  sops-nix from `secrets/secrets.yaml` (`OPENCODE/SERVER_PASSWORD`).

## Service

```bash
systemctl status opencode
journalctl -u opencode -f
systemctl restart opencode
ss -ltnp | grep 4096
```

## Security

- The service is **not hardened** on purpose: it must run `nixos-rebuild`, read
  `/root`, and manage every unit. The boundary is the tailnet plus Basic auth.
- `0.0.0.0:4096` is intentional. `tailscale0` is a trusted firewall interface, so
  the port is reachable only from the tailnet; public interfaces drop it.
- Never put this behind nginx or expose it publicly. Never disable the firewall
  to "fix" connectivity — check `tailscale status` on the phone instead.
- Anyone with the password (and tailnet access) is root. Rotate it with
  `sops set ... '["OPENCODE"]["SERVER_PASSWORD"]'`, then
  `systemctl restart opencode` (and update the app).
- If the app asks for tool permissions, the session is not in `/root/agent`.
  Switch the directory back to default; only `/root/agent/opencode.json` grants
  `allow`.

## Notes

- Phone notifications are local to the app; there is no push. Replies appear
  when the app is open.
- Updating `opencode` means a rebuild: it comes from `pkgs.unstable.opencode`.
- `share` is disabled and autoupdate is off (Nix manages the binary).
