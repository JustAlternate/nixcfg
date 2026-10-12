{ pkgs }:
with pkgs;
[
  steam
  mgba
  prismlauncher
  (pkgs.callPackage ../../packages/osu-lazer-telemetry { }) # osu-lazer-bin + local telemetry hook (score/acc/combo/pp/mods/beatmap/profile)
  wine
  winetricks
  wine-wayland
]
