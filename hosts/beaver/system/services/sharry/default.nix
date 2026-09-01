{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.sharry.nixosModules.default ];

  services = {
    sharry = {
      enable = true;
      package = inputs.sharry.packages.${pkgs.system}.sharry;
      config = {
        base-url = "https://share.justalternate.com";
        bind = {
          address = "127.0.0.1";
          port = 3042;
        };
        backend = {
          jdbc = {
            url = "jdbc:postgresql://127.0.0.1:5432/sharry";
            user = "sharry";
          };
          # fixed module is the bootstrap admin (user "admin");
          # password comes from SHARRY/ENV (SHARRY_BACKEND_AUTH_FIXED_PASSWORD)
          auth.fixed.enabled = true;
          signup.mode = "closed";
        };
      };
    };

    postgresql = {
      ensureDatabases = [ "sharry" ];
      ensureUsers = [
        {
          name = "sharry";
          ensureDBOwnership = true;
        }
      ];
    };

    nginx.virtualHosts."share.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3042";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          # tus uploads: stream large bodies and give slow uploads time
          client_max_body_size 1g;
          proxy_request_buffering off;
          proxy_connect_timeout   1m;
          proxy_send_timeout      10m;
          proxy_read_timeout      10m;
        '';
      };
    };
  };

  # ensureUsers creates the role without a password; set it from sops
  # before sharry tries to connect.
  systemd.services.sharry-db-setup = {
    description = "Sharry postgres role password bootstrap";
    after = [ "postgresql.service" ];
    before = [ "sharry.service" ];
    requiredBy = [ "sharry.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
      ExecStart = pkgs.writeShellScript "sharry-db-password" ''
        ${pkgs.postgresql}/bin/psql -d postgres -v ON_ERROR_STOP=1 -c "ALTER ROLE sharry PASSWORD '$(cat ${
          config.sops.secrets."SHARRY/DB_PASSWORD".path
        } | tr -d "[:space:]")'"
      '';
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
    };
  };

  systemd.services.sharry = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
    serviceConfig = {
      EnvironmentFile = config.sops.secrets."SHARRY/ENV".path;
      Restart = "on-failure";
      RestartSec = "10s";

      # Hardening (JVM service: MemoryDenyWriteExecute would break the JIT)
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectHostname = true;
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
      LockPersonality = true;
      CapabilityBoundingSet = "";
      # AF_NETLINK: JVM enumerates network interfaces via netlink
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
    };
  };
}
