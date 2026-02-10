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
      "SSO/GRAFANA_CLIENT_SECRET" = { };
      "VAULTWARDEN/ENV" = { };
      "OPENCLOUD/ENV" = { };
      "KEYCLOAK_ADMIN_PASSWORD" = { };
      "ROOT_SSH_AUTHORIZED_KEY" = { };
    };
  };

  environment = {
    systemPackages = with pkgs; [ sops ];
  };
}
