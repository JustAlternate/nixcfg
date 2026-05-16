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
    ./hardware.nix
    ../../../modules/nixos/tailscale.nix
    ../../../profiles/nixos/desktop
    ../../../profiles/nixos/desktop/yubikey.nix
    ../../../profiles/nixos/core/identity.nix
    ../../../profiles/nixos/core/nix.nix
    ../../../modules/nixos/sops.nix
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

      # Workspace-to-monitor bindings
      workspace = 1, monitor:DP-1
      workspace = 2, monitor:DP-1
      workspace = 5, monitor:HDMI-A-1

      # Auto-start applications on specific workspaces
      exec-once = [workspace 1 silent] ghostty --config-file=/home/justalternate/.config/ghostty/config
      exec-once = [workspace 2 silent] librewolf
      exec-once = [workspace 5 silent] vesktop
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
