{ pkgs, lib, ... }:
{
  # CONFIGURATION FOR A TUXEDO InfinityBook Pro 14 Gen10 AMD
  imports = [
    ./hardware.nix
    ../../../modules/nixos/tailscale.nix
    ../../../profiles/nixos/desktop
    ../../../profiles/nixos/desktop/yubikey.nix
    ../../../profiles/nixos/core/identity.nix
    ../../../profiles/nixos/core/nix.nix
    ../../../modules/nixos/sops.nix
  ];

  machineName = "eagle";
  networking.hostName = "eagle";

  # Podman instead of Docker (desktop profile enables docker; override here)
  virtualisation.docker.enable = lib.mkForce false;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    autoPrune.enable = true;
  };
  users.groups.podman.members = [ "justalternate" ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.kernelModules = [ "amdgpu" ];
  };

  services = {
    openssh.enable = true;

    xserver.videoDrivers = [ "amdgpu" ];

    # Low-power laptop: battery-aware power management
    upower.enable = true;

    tlp = {
      enable = true;
      settings = {
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
        AMDGPU_ABM_LEVEL_ON_BAT = 3;
        # Helps long-term battery health
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 90;
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      powertop
    ];
  };

  hardware = {
    bluetooth.enable = true;
    graphics.enable = true;
  };

  programs.hyprland = {
    settings.env = [
      "WLR_DRM_DEVICES,/dev/dri/card1"
    ];
    extraConfig = ''
      # Monitor settings
      monitor=eDP-1,2880x1800@60,0x0,2
    '';
  };

  system.stateVersion = "26.05";
}
