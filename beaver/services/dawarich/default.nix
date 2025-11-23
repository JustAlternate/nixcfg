{
  config,
  inputs,
  ...
}:
let
  domain = "geo.justalternate.com";
  port = 3001;
in
{
  services = {
    nginx.virtualHosts."geo.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";
        proxyWebsockets = true; # needed if you need to use WebSocket
      };
    };
  };

  imports = [
    (inputs.nixpkgs-dawarich-pr + "/nixos/modules/services/web-apps/dawarich.nix")
  ];

  services.dawarich = {
    enable = true;
    webPort = port;
    localDomain = domain;
    extraConfig = {
      STORE_GEODATA = "true";
      ENABLE_TELEMETRY = "false";
    };
  };

  # TODO: remove on 25.11
  # Compatibility with 25.11 modules due to changes in PostgreSQL module
  systemd.targets.postgresql = {
    description = "PostgreSQL";
    wantedBy = [ "multi-user.target" ];
    requires = [
      "postgresql.service"
      "postgresql-setup.service"
    ];
  };
  systemd.services.postgresql = {
    wants = [ "postgresql.target" ];
    partOf = [ "postgresql.target" ];
  };
  systemd.services.postgresql-setup = {
    description = "PostgreSQL Setup Scripts";

    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
    serviceConfig = {
      User = "postgres";
      Group = "postgres";
      Type = "oneshot";
      RemainAfterExit = true;
    };

    path = [ config.services.postgresql.finalPackage ];
    environment.PGPORT = builtins.toString config.services.postgresql.settings.port;
    script = ''
      echo dummy
    '';
  };

  modules.services.restic.paths = [
    "/var/lib/dawarich"
  ];
}
