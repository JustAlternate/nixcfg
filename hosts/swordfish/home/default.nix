{ pkgs, ... }:
{
  imports = [
    ../../../home
  ];

  home = {
    sessionPath = [
      "$HOME/go/bin"
    ];

    stateVersion = "24.11";

    packages = with pkgs; [
      gparted
      appimage-run
      opentabletdriver
      lego
      nvtopPackages.amd
    ];
  };
}
