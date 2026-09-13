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
    initrd = {
      kernelModules = [ "amdgpu" ];
      systemd.enable = true;
      # FIDO2 YubiKey unlock: touch-only (user-presence=yes, no PIN)
      # Enroll with: sudo systemd-cryptenroll --fido2-device=auto --fido2-with-client-pin=no --fido2-with-user-presence=yes --fido2-with-user-verification=no /dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee
      # --fido2-with-user-verification=no for now (no biometric). If you buy a YubiKey Bio later, re-enroll with =yes to require fingerprint.
      luks.devices."luks-46c64a55-12ec-4dca-a2cb-9be9687559ee" = {
        device = "/dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee";
        crypttabExtraOpts = [
          "fido2-device=auto"
          "token-timeout=30"
        ];
      };
    };
  };

  services = {
    openssh.enable = true;

    xserver.videoDrivers = [ "amdgpu" ];

    # Low-power laptop: battery-aware power management
    upower.enable = true;

    tlp = {
      enable = true;
      settings = {
        # Portable (battery)
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
        AMDGPU_ABM_LEVEL_ON_BAT = 3;
        # Plugged-in (AC)
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        PLATFORM_PROFILE_ON_AC = "performance";
        CPU_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_AC = 1;
        AMDGPU_ABM_LEVEL_ON_AC = 0;
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

  environment.etc."xdg/hypr/hyprland.conf".text = ''
    monitor = eDP-1, 2880x1800@120, 0x0, 1.5, vrr, 2, bitdepth, 10, cm, srgb
  '';

  system.stateVersion = "26.05";
}
