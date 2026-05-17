# Mail Service (beaver)

Self-hosted mail server using [simple-nixos-mailserver](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver), which bundles Postfix (SMTP), Dovecot (IMAP), and Rspamd (spam filtering).

## Configuration

- **FQDN:** `mail.justalternate.com`
- **Domains:** `justalternate.com`, `mail.justalternate.com`
- **DKIM:** 2048-bit RSA, selector `mail2024`
- **TLS:** ACME via nginx (Let's Encrypt), auto-reloads postfix/dovecot on renewal

## Accounts

| Account                       | Purpose                              |
|-------------------------------|--------------------------------------|
| `loicw@justalternate.com`     | Primary mailbox (+ postmaster alias) |
| `monitor@justalternate.com`   | Automated end-to-end probe           |

## Cloudflare Email Routing Fallback

Mail delivery uses Cloudflare as the sole MX. Cloudflare Email Routing forwards incoming mail to **both**:

- `loicw@mail.justalternate.com` → delivered directly to beaver via A record (port 25)
- `loic.weber@protonmail.com` → always receives a copy as redundancy

This means if beaver is offline, Proton still gets all mail instantly.

For this to work, beaver accepts mail for the `mail.justalternate.com` subdomain via an alias:

```nix
aliases = [
  "postmaster@justalternate.com"
  "loicw@mail.justalternate.com"
];
```

## Services

| Service        | Port  | Protocol  |
|----------------|-------|-----------|
| SMTP (SMTPS)   | 465   | Implicit TLS |
| IMAP (IMAPS)   | 993   | Implicit TLS |
| Submission     | 587   | STARTTLS |

Fail2ban jails are active on `postfix-sasl` and `dovecot`.

## Monitoring

A custom Go probe (`mail-monitor`) sends and receives a test email via the `monitor@` account every 5 minutes, exposing Prometheus metrics on `:9116`. A Grafana alert fires if the round-trip fails for 2+ minutes.