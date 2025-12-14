{ pkgs, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/nix/sops/age/keys.txt";
    secrets = {
      "MISTRAL_API_KEY" = { };
      "OPENROUTER_API_KEY" = { };
      "HASHED_PASSWORD" = { };
      "PASSWORD" = { };
      "EMAIL" = { };
      "VAULTWARDEN/ENV" = { };
      "PLANKA/SECRET_KEY" = { };
    };
  };

  environment = {
    systemPackages = with pkgs; [ sops ];
  };
}
