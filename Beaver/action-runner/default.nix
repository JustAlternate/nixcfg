{ pkgs, ... }:
{
  services.github-runners = {
    "nixcfg" = {
      enable = true;
      url = "https://github.com/JustAlternate/nixcfg";
      tokenFile = /run/secrets/ACTION_RUNNER/NIXCFG_TOKEN;
      extraPackages = with pkgs; [ nixfmt-rfc-style ];
    };
  };
}
