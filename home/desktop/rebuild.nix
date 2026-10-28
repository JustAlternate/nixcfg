{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "rebuild";
      runtimeInputs = [ pkgs.cachix ];
      text = ''
        action="''${1:-switch}"
        cd "''${NIXCFG:-$HOME/nixcfg}"
        exec sudo bash -c '
          set -euo pipefail
          . /run/secrets/cachix-env
          exec cachix watch-exec justalternate-nixcfg -- nixos-rebuild "$@"
        ' _ "$action" --flake ".#$(hostname)Nixos"
      '';
    })
  ];
}
