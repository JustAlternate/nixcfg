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
    # "~/.config/wal/templates" = ./template/;

    ".mozilla/native-messaging-hosts/pywalfox.json".text = lib.replaceStrings [ "<path>" ] [
      "${pywalfox-wrapper}/bin/pywalfox-wrapper"
    ]
      (lib.readFile "${pkgs.pywalfox-native}/lib/python3.11/site-packages/pywalfox/assets/manifest.json");
  };
}
