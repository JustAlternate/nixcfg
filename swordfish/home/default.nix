{ pkgs, ... }:
{
  imports = [
    ../../shared/home/desktop.nix
  ];

  home = {
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.11";

    packages = with pkgs; [
      grimblast
      gparted
      firefox
      mpv
      youtube-music
      ffmpeg
      imagemagick
      satty
      bemoji
      ultrastardx
      lutris
      godot3
      appimage-run
      pokemmo-installer
      opentabletdriver
      lego
    ];
  };
}
