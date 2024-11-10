{ pkgs, ... }:
{
  services.github-runner = {
    "nixcfg" = {
      tokenFile = /run/secrets/ACTION_RUNNER/NIXCFG_TOKEN;
      extraPackages = with pkgs; [
        nixfmt-rfc-style
      ];
    };
  };
}
