{ pkgs, ... }:
{
  imports = [
    ../../../home
  ];

  zsh.hyprlandAutostart.enable = true;

  home = {
    sessionPath = [
      "$HOME/go/bin"
    ];

    stateVersion = "26.05";

    packages = with pkgs; [
      upower
      brightnessctl
      pwvucontrol
    ];
  };
}
