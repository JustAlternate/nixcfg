{ pkgs, ... }:
{
  imports = [
    ../../shared/home/desktop.nix
  ];

  dconf.enable = true;

  home = {
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.05";

    packages = with pkgs; [
      chromium
      mousam
      wkhtmltopdf
      godot_4
      gdtoolkit_4
      steam-run-free
      upower
    ];
  };
}
