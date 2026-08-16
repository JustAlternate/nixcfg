{
  config,
  pkgs,
  ...
}:
{
  sops.secrets = {
    "RAUTHY/secrets.toml" = {
      owner = "rauthy";
      group = "rauthy";
      mode = "0400";
    };
    "RAUTHY/ADMIN_PASSWORD" = { };
    "RAUTHY/bootstrap/clients.json" = {
      owner = "rauthy";
      group = "rauthy";
      mode = "0400";
    };
    "RAUTHY/bootstrap/users.json" = {
      owner = "rauthy";
      group = "rauthy";
      mode = "0400";
    };
  };

  sops.templates."rauthy-admin-password" = {
    path = "/run/rauthy-admin-password";
    owner = "rauthy";
    group = "rauthy";
    mode = "0400";
    content = ''
      BOOTSTRAP_ADMIN_PASSWORD_PLAIN=${config.sops.placeholder."RAUTHY/ADMIN_PASSWORD"}
    '';
  };

  users.users.rauthy = {
    isSystemUser = true;
    group = "rauthy";
  };
  users.groups.rauthy = { };

  systemd.services.rauthy = {
    description = "Rauthy SSO (OpenID Connect + OAuth 2)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "postfix.service"
    ];

    serviceConfig = {
      ExecStart = "${pkgs.rauthy}/bin/rauthy serve --config-file ${./config.toml} --secrets-file ${config.sops.secrets."RAUTHY/secrets.toml".path}";
      Restart = "on-failure";
      RestartSec = "30s";

      User = "rauthy";
      Group = "rauthy";
      StateDirectory = "rauthy";
      EnvironmentFile = "/run/rauthy-admin-password";

      # Hardening
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      CapabilityBoundingSet = "";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      SystemCallArchitectures = "native";
      LockPersonality = true;
    };
  };

  services.nginx.virtualHosts."auth.justalternate.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3127";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };
}
