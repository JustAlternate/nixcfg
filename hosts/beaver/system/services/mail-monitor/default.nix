{
  config,
  pkgs,
  ...
}:

let
  mail-monitor = pkgs.buildGoModule {
    pname = "mail-monitor";
    version = "1.0.0";
    src = ./.;
    vendorHash = "sha256-0QJ3mBuXqtZymBoic2BAiBK2F6d8WJ5o0Xah4Pld6Mg=";
  };
in
{
  systemd.services.mail-monitor = {
    description = "Mail end-to-end probe — send & receive test via SMTP/IMAP";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "postfix.service"
      "dovecot2.service"
    ];

    serviceConfig = {
      ExecStart = "${mail-monitor}/bin/mail-monitor";
      Restart = "on-failure";
      RestartSec = "30s";

      EnvironmentFile = config.sops.secrets."MAIL_MONITOR/ENV".path;

      # Hardening
      DynamicUser = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      CapabilityBoundingSet = "";
    };

    # Static config via environment (non-secret values)
    environment = {
      SMTP_HOST = "localhost";
      SMTP_PORT = "465";
      IMAP_HOST = "localhost";
      IMAP_PORT = "993";
      MAIL_FROM = "monitor@justalternate.com";
      MAIL_TO = "monitor@justalternate.com";
      SMTP_USER = "monitor@justalternate.com";
      IMAP_USER = "monitor@justalternate.com";
      PROBE_INTERVAL = "5m";
      RECEIVE_TIMEOUT = "60s";
      METRICS_PORT = "9116";
    };
  };
}
