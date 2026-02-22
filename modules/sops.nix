{ pkgs, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
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
      "VAULTWARDEN/ENV" = { };
      "OPENCLOUD/ENV" = { };
      "OPENWEBUI/ENV" = { };
    };
  };

  environment = {
    systemPackages = with pkgs; [ sops ];
  };
}
