{ pkgs, ... }:
{
  imports = [
    ../../../home
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
      gparted
      appimage-run
      opentabletdriver
      lego
      nvtopPackages.amd
    ];
  };
}
