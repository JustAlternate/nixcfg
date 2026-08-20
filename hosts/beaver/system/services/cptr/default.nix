{
  config,
  pkgs,
  ...
}:
let
  cptrPkg = pkgs.callPackage ../../../../../packages/cptr { };
in
{
  sops.secrets = {
    "CPTR/COOKIE_SECRET" = { };
    "CPTR/OAUTH_CLIENT_SECRET" = { };
    # GitHub SSH identity so the agent can push from its workspaces. Same key as
    # /root/.ssh/id_ed25519 (reused, not a new deploy key). Rendered by sops-nix
    # directly into cptr's ~/.ssh so git/ssh pick it up without extra setup.
    "CPTR/GITHUB_SSH_KEY" = {
      path = "/var/lib/cptr/.ssh/id_ed25519";
      owner = "cptr";
      group = "cptr";
      mode = "0600";
    };
  };

  users.users.cptr = {
    isSystemUser = true;
    group = "cptr";
    home = "/var/lib/cptr";
    shell = pkgs.zsh;
  };
  users.groups.cptr = { };

  systemd.services.cptr = {
    description = "Open WebUI Computer (cptr)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [
      pkgs.git
      pkgs.gh
    ];

    serviceConfig = {
      User = "cptr";
      Group = "cptr";
      StateDirectory = "cptr";
      WorkingDirectory = "/var/lib/cptr";
      Environment = [
        "CPTR_DATA_DIR=/var/lib/cptr"
        "CPTR_CORS_ALLOWED_ORIGINS=https://computer.justalternate.com"
        "SHELL=/run/current-system/sw/bin/zsh"
        # Only nginx (127.0.0.1) ever talks to cptr, so uvicorn must NOT trust
        # proxy headers: otherwise ProxyHeadersMiddleware rewrites client.host
        # from X-Forwarded-For to the real client IP, which fails cptr's
        # trusted_sources=["127.0.0.1"] check -> "auth not configured".
        # Empty value = no proxy is trusted, client.host stays 127.0.0.1.
        "FORWARDED_ALLOW_IPS="
      ];
      # Seed config.toml (trusted_header SSO) on first run only.
      ExecStartPre = pkgs.writeShellScript "cptr-seed-config" ''
        if [ ! -f /var/lib/cptr/config.toml ]; then
          cat > /var/lib/cptr/config.toml <<'EOF'
        [auth]
        mode = "trusted_header"
        header = "X-Email"
        trusted_sources = ["127.0.0.1"]
        EOF
          chown cptr:cptr /var/lib/cptr/config.toml
        fi
      '';
      ExecStart = "${cptrPkg}/bin/cptr run --host 127.0.0.1 --port 8000 --headless";
      Restart = "on-failure";
      RestartSec = 5;

      # cptr is an interactive executor: it spawns shells, runs git/nix, and
      # relies on sudo for privileged ops. The standard beaver hardening
      # template (NoNewPrivileges/ProtectSystem/ProtectHome/CapabilityBoundingSet)
      # would break the terminal and sudo, so the security boundary is instead:
      #   - unprivileged `cptr` user (not root)
      #   - loopback-only bind (127.0.0.1)
      #   - Rauthy SSO in front (oauth2-proxy → trusted_header)
      #   - narrowly-scoped sudo (nixos-rebuild only)
      NoNewPrivileges = false;
      ProtectSystem = false;
      ProtectHome = false;
    };
  };

  # Direct access to /root (the actual data home) for cptr, for the file browser
  # without needing sudo. A+ = append ACLs recursively, so it also covers existing
  # content (a plain "a+" would only touch the top dir). cptr already has
  # passwordless sudo for all commands, so this does not widen the security boundary.
  #
  # The A+ rule also recurses into /root/.ssh and clobbers the mode on the private
  # key (ACL mask->rwx means group-writable), which makes OpenSSH refuse it. The
  # `z` lines below pin /root/.ssh back down afterwards so git/ssh keep working.
  # Non-recursive `z` (not `Z`): a recursive `Z /root/.ssh` would re-clobber the
  # per-key modes below it. Order within the file: A+ first, then z lines.
  systemd.tmpfiles.rules = [
    "A+ /root - - - - u:cptr:rwx,d:u:cptr:rwx"
    "z /root/.ssh 0700 root root -"
    "z /root/.ssh/id_ed25519 0600 root root -"
    "z /root/.ssh/id_ed25519.pub 0644 root root -"
    # cptr's SSH home (sops renders CPTR/GITHUB_SSH_KEY here).
    "d /var/lib/cptr/.ssh 0700 cptr cptr -"
  ];

  # Full passwordless sudo: cptr may manage services, /var, and run nixos-rebuild.
  security.sudo.extraRules = [
    {
      users = [ "cptr" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # SSO: oauth2-proxy validates the Rauthy OIDC session, then nginx sets the
  # X-User header that cptr trusts (trusted_header mode).
  services.oauth2-proxy = {
    enable = true;
    provider = "oidc";
    # Trailing slash is significant: oauth2-proxy must match Rauthy's issuer
    # string exactly (".../auth/v1/") or OIDC discovery fails.
    oidcIssuerUrl = "https://auth.justalternate.com/auth/v1/";
    clientID = "cptr";
    clientSecretFile = config.sops.secrets."CPTR/OAUTH_CLIENT_SECRET".path;
    cookie.secretFile = config.sops.secrets."CPTR/COOKIE_SECRET".path;
    email.domains = [ "justalternate.com" ];
    setXauthrequest = true;
    # Rauthy requires PKCE for this client; oauth2-proxy must opt in.
    extraConfig."code-challenge-method" = "S256";
    # Must include the scheme: the oauth2-proxy-nginx module reuses this as the
    # nginx proxy_pass target, which requires a URL (not a bare host:port).
    httpAddress = "http://127.0.0.1:4180";
    redirectURL = "https://computer.justalternate.com/oauth2/callback";
    reverseProxy = true;
    trustedProxyIP = [ "127.0.0.1/32" ];
    nginx = {
      domain = "computer.justalternate.com";
      virtualHosts."computer.justalternate.com" = {
        allowed_email_domains = [ "justalternate.com" ];
      };
    };
  };

  services.nginx.virtualHosts."computer.justalternate.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8000";
      proxyWebsockets = true;
      extraConfig = ''
        # cptr is Socket.IO + terminal WebSockets; keep long-lived connections alive.
        proxy_read_timeout 86400s;
      '';
    };
  };
}
