{ pkgs
, lib
, inputs
, ...
}:
let
  pywalfox-wrapper = pkgs.writeShellScriptBin "pywalfox-wrapper" ''
    ${pkgs.pywalfox-native}/bin/pywalfox start
  '';
in
{
  home.packages = with pkgs; [
    pywal
    pywalfox-native
    inputs.themecord.packages.x86_64-linux.default
  ];

  home.file = {
    "~/.config/wal/templates/cava_conf" = ./template/cava_conf;
    "~/.config/wal/templates/color-rofi" = ./template/color-rofi;
    "~/.config/wal/templates/colors-hypr" = ./template/colors-hypr;
    "~/.config/wal/templates/colors-discord" = ./template/colors-discord.css;

    ".mozilla/native-messaging-hosts/pywalfox.json".text = lib.replaceStrings [ "<path>" ] [
      "${pywalfox-wrapper}/bin/pywalfox-wrapper"
    ]
      (lib.readFile "${pkgs.pywalfox-native}/lib/python3.11/site-packages/pywalfox/assets/manifest.json");
  };
}
