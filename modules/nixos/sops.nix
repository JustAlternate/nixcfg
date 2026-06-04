{ pkgs, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/root/.config/sops/age/keys.txt";
    secrets = {
      "MISTRAL_API_KEY" = { };
      "OPENROUTER_API_KEY" = { };
      "HASHED_PASSWORD" = { };
      "PASSWORD" = { };
      "EMAIL" = { };
      "SSO/DAWARICH_CLIENT_SECRET" = { };
      "GRAFANA/ENV" = { };
      "GRAFANA/SECRET_KEY" = {
        owner = "grafana";
        mode = "0400";
      };
      "VAULTWARDEN/ENV" = { };
      "VAULTWARDEN/SSO_KEY" = { };
      "OPENCLOUD/ENV" = { };
      "OPENWEBUI/ENV" = { };
      "GOTIFY/ENV" = { };
      "GOTIFY/APP_TOKEN" = { };
      "MAIL_MONITOR/HASHED_PASSWORD" = { };
      "MAIL_MONITOR/ENV" = { };
      "HEADSCALE/PREAUTH_KEY" = { };
    };
  };

  environment = {
    systemPackages = with pkgs; [ sops ];
  };
}
