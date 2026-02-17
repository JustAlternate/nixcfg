{
  pkgs,
  ...
}:
{
  # CONFIGURATION FOR A HOMEMADE GAMING RIG FEATURING
  # Motherboard: B550 GAMING X
  # CPU: AMD Ryzen 7 5800X
  # GPU: AMD Radeon RX 6800
  # RAM: 32G
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../shared/system/desktop.nix
    ../shared/machine-name.nix
  ];

  machineName = "swordfish";

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.kernelModules = [ "amdgpu" ];
  };

  services = {
    openssh.enable = true;

    xserver = {
      videoDrivers = [ "amdgpu" ];
      wacom.enable = true;
    };

    ollama = {
      enable = true;
      package = pkgs.unstable.ollama-rocm;
      rocmOverrideGfx = "10.3.0";
    };
  };

  hardware = {
    # ckb-next.enable = true;
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };

  programs.hyprland = {
    extraConfig = ''
      # Monitor settings
      monitor=DP-3, 2560x1440@165, 1920x0, 1
      monitor=DP-1, 2560x1440@165, 1920x0, 1
      monitor=HDMI-A-1, 1920x1080@60, 0x0, 1
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";
}
