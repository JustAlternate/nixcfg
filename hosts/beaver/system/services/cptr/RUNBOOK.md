# cptr (Open WebUI Computer) — RUNBOOK

Your whole beaver machine in a browser: files, terminal, git, editor, AI agent.
Replaces the old `opencode-server` + `mcp-opencode-bridge` MCP hack.

## Architecture

```
Browser ──HTTPS──▶ nginx (computer.justalternate.com)
                     │ auth_request /oauth2/auth
                     ▼
                oauth2-proxy (127.0.0.1:4180) ──OIDC──▶ Rauthy (auth.justalternate.com)
                     │ sets X-Auth-Request-User
                     ▼
                nginx proxy_set_header X-User → cptr (127.0.0.1:8000)
                     │ trusted_header auth mode (trusts X-User only from 127.0.0.1)
                     ▼
                cptr (unprivileged `cptr` user, passwordless sudo for all commands)
```

Open WebUI integration is separate: Open WebUI connects to cptr's OpenAI-compatible
gateway at `http://127.0.0.1:8000/v1` over loopback with a `sk-cptr-…` API key
(no public exposure, no SSO — key-auth only). Each workspace appears in Open WebUI's
model picker as `cptr/<workspace>`.

## Security model

- **Loopback only**: cptr binds `127.0.0.1:8000`; only nginx reaches it.
- **Rauthy SSO**: oauth2-proxy validates the OIDC session; nginx *owns* the `X-User`
  header (cptr `trusted_sources = ["127.0.0.1"]`). A signed-in user = full machine
  access, equivalent to SSH. Only `@justalternate.com` emails are allowed.
- **Unprivileged**: the service runs as the `cptr` user (not root).
- **Passwordless sudo**: `cptr` has passwordless sudo for all commands to manage systemd,
  `/var`, and `nixos-rebuild`; `/root` (the data home) is directly accessible via POSIX ACLs.
- **No localhost bypass**: cptr has no auth bypass; every request authenticates.

## First-time setup (one-time)

1. DNS: point `computer.justalternate.com` → beaver (`195.201.116.51`), then rebuild
   so ACME can issue the cert.
2. Open `https://computer.justalternate.com` — you'll be redirected through Rauthy.
   First login auto-creates a `pending` user.
3. Promote it to admin (one-time):
   ```bash
   sudo sqlite3 /var/lib/cptr/app.db "UPDATE users SET role='admin';"
   ```
4. Reload the page (sliding session refreshes the JWT role).

## Wire Open WebUI → cptr (gateway)

1. In cptr, **Settings → Admin → Gateway** → create an API key (`sk-cptr-…`, shown once).
2. In Open WebUI, **Admin Settings → Connections → OpenAI API**:
   - Base URL: `http://127.0.0.1:8000/v1`
   - API key: the `sk-cptr-…` key
   - Custom headers:
     ```json
     {
       "X-OpenWebUI-Chat-Id": "{{CHAT_ID}}",
       "X-OpenWebUI-Message-Id": "{{MESSAGE_ID}}",
       "X-OpenWebUI-User-Message-Id": "{{USER_MESSAGE_ID}}",
       "X-OpenWebUI-User-Message-Parent-Id": "{{USER_MESSAGE_PARENT_ID}}",
       "X-OpenWebUI-Task": "{{TASK}}"
     }
     ```
3. Workspaces now show up in Open WebUI as `cptr/<workspace>`.
   Note: gateway tasks run the full agent loop with no per-action confirmation —
   keep the key private.

## Bump cptr version

Edit `packages/cptr/default.nix`: change `version` + `sha256` (get the hash with
`nix hash file <downloaded .whl>`). The wheel bundles the prebuilt frontend, so no
Node toolchain is involved.

## Ops

```bash
journalctl -u cptr -f                 # logs
sudo systemctl restart cptr           # restart
sudo -u cptr cat /var/lib/cptr/config.toml   # auth config
```

## Troubleshooting

- **Gateway auth fails**: `curl -H "Authorization: Bearer sk-cptr-…" http://127.0.0.1:8000/v1/models`
  — separates connectivity (base URL ends `/v1`) from key/model issues.
- **Terminal/sockets broken**: nginx must forward WebSocket upgrades (it does,
  via `proxyWebsockets` + `proxy_read_timeout 86400s`).
- **Locked out / rotate all sessions**: replace `[server] secret` in
  `/var/lib/cptr/config.toml`, restart, re-enter provider keys and rotate gateway keys.
