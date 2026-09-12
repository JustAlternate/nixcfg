# Open WebUI — RUNBOOK

Chat UI for the LLM stack: the full OpenRouter catalog plus cptr workspaces.
Served at `https://ai.justalternate.com` (nginx reverse-proxies to loopback).

## Architecture

```
Browser ──HTTPS──▶ nginx (ai.justalternate.com)
                     ▼
                open-webui (127.0.0.1:3040)
                     │  provider connections (Admin Settings → Connections)
                     ├─ OpenRouter  https://openrouter.ai/api/v1   (sk-or-…)
                     └─ cptr        http://127.0.0.1:8000/v1       (sk-cptr-…)
```

- **Auth**: Rauthy OIDC (`ENABLE_PASSWORD_AUTH=false`, login form off). OIDC client
  secret lives in the sops `OPENWEBUI/ENV` environment file.
- **State**: SQLite at `/var/lib/open-webui/data/webui.db` (owned by `nobody`, mode 0600).
- **Secrets**: sops `OPENWEBUI/ENV` is injected via `environmentFile`. Caveat: the
  `OPENAI_API_*` variables in that file only *seed* the DB through the config
  migration; at runtime Open WebUI reads connections from the DB (`config` table),
  so the admin UI is authoritative for providers.

## Model visibility (read this before touching the admin UI)

Open WebUI 0.11 builds its model list from two sources:

1. **Provider models** — fetched live from each enabled connection.
2. **Workspace "override" rows** — rows in the `model` table with
   `base_model_id = NULL` that share an id with a provider model.

`open_webui/utils/models.py:get_all_models()` then does:

- active override (`is_active = 1`) → replaces the provider model's metadata;
- **inactive override (`is_active = 0`) → removes the provider model entirely.**

The Admin → Models "create/sync" flow writes those rows **inactive**, so every model
you touch there disappears from the chat model picker. The only models that keep
showing are those with no workspace row (the cptr workspaces).

**Rule: never use Admin → Models to "pick" OpenRouter models.** They are already
available once the OpenRouter connection is enabled. If shadows reappear, run
`owui-models`.

### owui-models

On-demand reconciler (package `packages/owui-models`, installed on beaver):

```bash
owui-models          # dry run: report + what would be removed
owui-models --apply  # delete inactive override rows, checkpoint WAL
```

It keeps active overrides, reads connection URLs/keys from the DB at runtime (no
secrets in nix), and is safe to re-run.

**Access**: `BYPASS_MODEL_ACCESS_CONTROL=true` is set for the service so every
visible model is usable by any signed-in user. This is a 2-person instance; there
are no per-model access grants.

## Ops

```bash
journalctl -u open-webui -f
sudo systemctl restart open-webui
```

Inspect workspace overrides:

```bash
sudo sqlite3 /var/lib/open-webui/data/webui.db \
  "SELECT id, is_active FROM model WHERE base_model_id IS NULL;"
```

Backup (stop the service for a consistent copy):

```bash
sudo systemctl stop open-webui
sudo cp /var/lib/open-webui/data/webui.db{,-wal,-shm} /root/webui-backup-$(date +%F)/
sudo systemctl start open-webui
```

## Connections

Manage providers in **Admin Settings → Connections**:

- OpenRouter: `https://openrouter.ai/api/v1` + `sk-or-…`.
- cptr gateway: `http://127.0.0.1:8000/v1` + `sk-cptr-…`, with the `X-OpenWebUI-*`
  chat-context headers (see the cptr RUNBOOK).

## Troubleshooting

- **"Only cptr models show"**: inactive override shadows. Check
  `SELECT COUNT(*) FROM model WHERE base_model_id IS NULL AND is_active = 0;`
  then `sudo owui-models --apply` and hard-refresh.
- **Model still not visible after fixing the DB**: browser cache — hard refresh
  (Ctrl-Shift-R). `models.base_models_cache` is on, so the provider list is also
  cached in-process; a service restart forces a refetch.
