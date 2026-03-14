{
  modulesPath,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./default.nix
    ./hardware-pi3b+.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Static IP configuration
  networking = {
    hostName = "geckoNixos3";
    useDHCP = lib.mkForce false;
    nameservers = [ "192.168.1.1" ];
    interfaces.enu1u1 = {
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
  };

  # X11 + Openbox with startx (simple auto-login)
  services.xserver = {
    enable = true;
    windowManager.openbox.enable = true;
    displayManager = {
      lightdm.enable = lib.mkForce false;
      startx.enable = true;
    };
  };

  # Auto-start X on tty1 login
  programs.zsh.loginShellInit = ''
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec startx
    fi
  '';

  services.getty.autologinUser = "root";

  # Create /root/.xinitrc for startx - launches openbox + firefox
  system.activationScripts.rootXinitrc = ''
    mkdir -p /root
    cat > /root/.xinitrc << 'EOF'
    # Start openbox in background
    openbox-session &

    # Wait for openbox to start
    sleep 2

    # Launch Firefox in kiosk mode
    exec firefox --kiosk https://justalternate.com
    EOF
    chmod 644 /root/.xinitrc
  '';

  # Packages for kiosk
  environment.systemPackages = with pkgs; [
    firefox
    openbox
    xorg.xrandr
    xorg.xinit
  ];
}
