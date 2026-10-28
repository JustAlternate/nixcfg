# Concierge — Product Brief

Status: **draft for approval**. No code yet. See [TECHSPEC.md](TECHSPEC.md) for implementation details.

## One-liner

A weekly household brief for beaver: one automated caretaker that watches security,
maintenance, and drift, keeps a shared logbook for the agents, and only interrupts
the user when something actually needs a decision.

## Why

AI-assisted attacks are cheap and constant, and a self-hosted box accumulates small
problems silently: outdated flake inputs, a service bound too widely, a backup that
stopped, docs that no longer match the config, a secret accidentally committed to a
public repo. The existing Grafana/Prometheus/Loki stack answers "is it up right now?"
but nobody answers "is the house still in good shape, and what changed this week?".

The user reads everything on a phone. They do not want a dashboard, a scanner dump,
or a stream of alerts. They want a short, regular, trustworthy letter.

## Users

- **The owner** — reads the weekly brief on a phone, decides what to fix.
- **Agents** — the opencode assistant(s) that act on beaver. They need shared memory
  of what was done, why, and what is left for the next agent/session.
- **Future hosts** — gecko/desktops may join later, but the product must work for
  one host first.

## What it is

1. **A watch** — security posture, CVEs that matter, drift in the public `nixcfg`
   repo (especially `home/`), backups, certificates, services, resources.
2. **A caretaker** — spots what is aging or growing, proposes cleanup, and eventually
   performs a small allowlist of reversible chores.
3. **A logbook** — an append-only, tamper-evident journal shared by all agents,
   with explicit handoffs between sessions.

## What it is not

- Not a real-time monitoring system. Prometheus/Grafana/alerting stay the source of
  truth for uptime and incidents.
- Not an auto-remediation bot. It never runs `nixos-rebuild switch`, never touches
  mail/Vaultwarden/headscale, never restores or prunes backups, never changes DNS or
  firewall.
- Not a public dashboard. Reports stay on the host and arrive by notification/email.
- Not an LLM-first product. Facts are deterministic; an LLM may summarize later,
  but must never be the only thing between a CVE and the user.

## The weekly ritual

Every Sunday morning (Europe/Paris, persisted if the host was off) the concierge:

1. Collects facts from the host (no network).
2. Audits the repo snapshot and dependencies, queries CVE/exploit intelligence.
3. Writes one brief, archives the machine-readable findings, appends to the logbook.
4. Sends the brief by email, and a short notification by Gotify only if needed.

The brief is capped at roughly one phone screen of decisions plus a technical annex.

### Brief anatomy

1. **TL;DR** — 3 lines: is the house okay, what changed, what needs a decision.
2. **Action required** — table of findings with severity, why it matters, proposed
   action, effort. Empty is a valid and expected state.
3. **House state** — services, backups, certificates, mail, resources.
4. **What is growing / aging** — disk, store, generations, flake inputs, docs drift.
5. **Security & CVEs** — only relevant items, known-exploited first, with versions.
6. **Repo & home config** — secret leaks, risky patterns, lint/format/eval status.
7. **What the concierge did** — chores performed (or explicitly "nothing").
8. **Annex** — checks run, checks that failed to run, allowlisted findings.

## Severity model

- **CRITICAL** — interrupt now: known-exploited CVE on an installed version, secret
  found in the public repo, unexpected public port, backup too old, failed service,
  certificate about to expire, agent endpoint reachable outside the tailnet.
- **WARN** — goes in the weekly brief: high CVE not exploited, flake input age,
  disk/store/generation growth, lint or docs drift, expiring allowlist entry.
- **INFO** — archived only: inventory, versions, counts.

A failed scan is never reported as "all clear". A partial run is marked PARTIAL and
notified as WARN.

## Autonomy ladder

| Mode | Behavior | Default |
|---|---|---|
| `observe` | Read-only. Report and notify. | yes |
| `propose` | Adds ready-to-review proposals/patches, applies nothing. | later |
| `act` | Runs an explicit, reversible chore allowlist. | after 4 clean briefs |

Chores must be things NixOS does not already do (see TECHSPEC). Anything destructive,
stateful, or hard to reverse stays a proposal forever.

## Logbook

- One append-only JSONL journal on the host, shared by root-run agents and the
  concierge. Human-readable via CLI, tamper-evident via hash chain.
- Agents read the last entries at session start, log non-trivial actions, and can leave
  a `handoff` for the next agent.
- Never in the public `nixcfg` repo. Never contains secrets; entries are scrubbed and
  rejected if they look like credentials.
- Retention: 12 months, monthly files, compressed after 3 months.

## Notification rules

- CRITICAL → Gotify immediately + email.
- WARN / weekly digest → email only; Gotify only if the user opted in.
- OK → archived, no notification.
- No brief for more than 8 days → Grafana alert, so a dead timer cannot go unnoticed.
- Reports are never served publicly.

## Principles

- **Facts before opinions.** Every claim links to a check ID and raw evidence.
- **No silent suppression.** Exceptions are explicit, justified, and expire.
- **Prefer reversible.** Read, report, propose; act only on an allowlist.
- **Respect the phone.** Short brief, technical detail in the annex.
- **Privilege separation.** Root collection and untrusted-feed parsing never happen in
  the same process.
- **Public repo discipline.** Anything that touches findings stays local; the repo only
  holds generic rules and thresholds.

## Success metrics

- 3 consecutive weekly briefs delivered, each produced in under 10 minutes.
- Zero false CRITICALs in the first month; every CRITICAL leads to a real action.
- The silent-timer alert is proven by an intentional skipped run.
- Secrets found in the public repo are caught before (or instead of) a third party.
- Agents actually use the logbook: at least one handoff entry per multi-session task.

## Roadmap

1. **Docs + approval** (this).
2. **MVP observe** — collector, analyzers, report, Gotify/email, silence alert.
3. **Logbook** — journal CLI + AGENTS.md convention.
4. **Propose** — proposals section, no writes outside state.
5. **Act** — small chore allowlist after a clean track record.
6. **Optional triage** — local-only LLM summary, no webfetch, no auto-apply.

## Open decisions

- Language of the brief: French user-facing, English identifiers/annex (proposed).
- Gotify: create a dedicated app token for the concierge (manual, then sops).
- NVD API key: only if vulnix rate limits become a problem.
- Whether to add gitleaks CI on GitHub in addition to the weekly local scan.
- Report retention: 12 months proposed.
