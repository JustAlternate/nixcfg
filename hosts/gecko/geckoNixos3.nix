{ modulesPath, pkgs, ... }:
{
  imports = [
    ./default.nix
    ./hardware-pi3b+.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "geckoNixos3";

  # Static IP configuration
  networking.useDHCP = false;
  networking.interfaces.end0 = {
    ipv4.addresses = [
      {
        address = "192.168.1.13";
        prefixLength = 24;
      }
    ];
    ipv4.routes = [
      {
        address = "0.0.0.0";
        prefixLength = 0;
        via = "192.168.1.1";
      }
    ];
  };

  # X11 + Openbox with LightDM display manager
  services.xserver = {
    enable = true;
    windowManager.openbox.enable = true;
    displayManager.lightdm.enable = true;
    displayManager.lightdm.greeter.enable = true;
    displayManager.lightdm.greeter.package = pkgs.lightdm-gtk-greeter;
  };

  # Autologin as root via LightDM
  services.displayManager.autoLogin = {
    enable = true;
    user = "root";
  };

  # Root user with no password
  users.users.root.password = "";

  # Packages for kiosk: Chromium, Openbox, and xrandr for display debugging
  environment.systemPackages = with pkgs; [
    chromium
    openbox
    xorg.xrandr
  ];

  # Openbox autostart: launch Chromium in kiosk mode
  environment.etc."xdg/openbox/autostart".text = ''
    chromium --kiosk --no-sandbox --disable-infobars https://justalternate.com &
  '';
}
