{ pkgs }:
with pkgs;
[
  steam
  mgba
  prismlauncher
  pkgs.unstable.osu-lazer-bin # pin reason: fast-moving desktop game, needs latest for multiplayer compat
  wine
  winetricks
  wine-wayland
]
