{ pkgs, ... }:
{
  services.github-runners = {
    "nixcfg" = {
      user = "root"; # TODO: Fix SOPS on beaver to be able to remove this for the CI.
      enable = true;
      url = "https://github.com/JustAlternate/nixcfg";
      tokenFile = /run/secrets/ACTION_RUNNER/NIXCFG_TOKEN;
      extraPackages = with pkgs; [
        nixfmt-rfc-style
        statix
        deadnix
      ];
    };
  };
}
