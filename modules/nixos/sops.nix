{ pkgs, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/root/.config/sops/age/keys.txt";
    secrets = {
      # Shared across all hosts
      "HEADSCALE/PREAUTH_KEY" = { }; # tailscale auth (modules/nixos/tailscale.nix)
      "MISTRAL_API_KEY" = { };
      "OPENROUTER_API_KEY" = { };
    };
  };

  environment = {
    systemPackages = with pkgs; [ sops ];
  };
}
