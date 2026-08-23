{ config, pkgs, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/root/.config/sops/age/keys.txt";
    secrets = {
      # Shared across all hosts
      "HEADSCALE/PREAUTH_KEY" = { }; # tailscale auth (modules/nixos/tailscale.nix)
      "OPENROUTER_API_KEY" = { };
    };

    templates."llm-env" = {
      path = "/run/secrets/llm-env";
      mode = "0400";
      content = ''
        export OPENROUTER_API_KEY='${config.sops.placeholder.OPENROUTER_API_KEY}'
      '';
    };
  };

  environment = {
    systemPackages = with pkgs; [ sops ];
  };
}
