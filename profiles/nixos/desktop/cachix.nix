{ config, pkgs, ... }:
{
  nix.settings = {
    substituters = [ "https://justalternate-nixcfg.cachix.org" ];
    trusted-public-keys = [
      "justalternate-nixcfg.cachix.org-1:Bzqq/ByZOKxWH3ByZ0EWs2e+U7sP15yC0/15auvsR2k="
    ];
  };

  environment.systemPackages = [ pkgs.cachix ];

  sops.secrets."CACHIX_AUTH_TOKEN" = { };

  sops.templates."cachix-env" = {
    path = "/run/secrets/cachix-env";
    owner = "justalternate";
    group = "users";
    mode = "0400";
    content = ''
      export CACHIX_AUTH_TOKEN='${config.sops.placeholder.CACHIX_AUTH_TOKEN}'
    '';
  };
}
