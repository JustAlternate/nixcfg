_: {
  # Beaver-only server secrets. Declaring them here (instead of the shared
  # modules/nixos/sops.nix) keeps them off the desktop/laptop machines.
  sops.secrets = {
    "HASHED_PASSWORD" = { };
    "PASSWORD" = { };
    "SSO/DAWARICH_CLIENT_SECRET" = { };
    "GRAFANA/ENV" = { };
    "GRAFANA/SECRET_KEY" = {
      owner = "grafana";
      mode = "0400";
    };
    "VAULTWARDEN/ENV" = { };
    "VAULTWARDEN/SSO_KEY" = { };
    "OPENWEBUI/ENV" = { };
    "GOTIFY/ENV" = { };
    "GOTIFY/APP_TOKEN" = { };
    "MAIL_MONITOR/HASHED_PASSWORD" = { };
    "MAIL_MONITOR/ENV" = { };
    "OPENCODE_SERVER_PASSWORD" = { };
  };
}
