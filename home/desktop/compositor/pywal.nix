{ pkgs, ... }:
# let
#   pywalfox-wrapper = pkgs.writeShellScriptBin "pywalfox-wrapper" ''
#     ${pkgs.pywalfox-native}/bin/pywalfox start
#   '';
# in
{
  home.packages = with pkgs; [
    pywal
    pywalfox-native
  ];

  xdg.configFile."wal/templates/".source = ./pywal-templates;

  # Ensure the wal cache dir exists with a default colors file before the first
  # `wal` run, so Hyprland's `source = ~/.cache/wal/colors-hypr` never hits a
  # "globbing error: found no match" on first login.
  home.activation.ensureWalCache = ''
    $DRY_RUN_CMD mkdir -p "$HOME/.cache/wal"
    $DRY_RUN_CMD cp -n "${./pywal/default-colors-hypr}" "$HOME/.cache/wal/colors-hypr"
    $DRY_RUN_CMD chmod 600 "$HOME/.cache/wal/colors-hypr"
  '';

  # home.file = {
  #   ".mozilla/native-messaging-hosts/pywalfox.json".text =
  #     lib.replaceStrings [ "<path>" ] [ "${pywalfox-wrapper}/bin/pywalfox-wrapper" ]
  #       (lib.readFile "${pkgs.pywalfox-native}/lib/python3.11/site-packages/pywalfox/assets/manifest.json");
  # };
}
