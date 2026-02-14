{
  config,
  pkgs,
  ...
}:
{
  # CONFIGURATION FOR A ASUS TUF Gaming A15 FA506ICB_FA506ICB
  imports = [
    ./hardware-configuration.nix
    ../shared/system/desktop.nix
    ../shared/machine-name.nix
  ];

  machineName = "parrot";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GBM_BACKEND = "nvidia_drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    __NV_PRIME_RENDER_OFFLOAD = "1";
  };

  # Bootloader.
  boot = {
    extraModprobeConfig = ''
      # Avoid PCIe power‑save on MediaTek Wi‑Fi (prevents driver‑own‑failed loops)
      options mt7921e disable_aspm=1
      options mt76 disable_runtime_pm=1
    '';

    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
  };

  services = {
    xserver = {
      # Load nvidia driver for Xorg and Wayland
      videoDrivers = [
        # "nvidia" #disable nvidia here to save on battery
        "amdgpu"
      ];
    };

    getty = {
      autologinUser = "justalternate";
    };

    upower.enable = true;

    tlp = {
      enable = true;
      settings = {
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
        AMDGPU_ABM_LEVEL_ON_BAT = 3;
        #Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 75; # and bellow it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 90; # and above it stops charging
        RUNTIME_PM_BLACKLIST = "03:00.0";
      };
    };
  };

  hardware = {
    # bluetooth:
    bluetooth.enable = true;

    # Enable OpenGL
    graphics = {
      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = true;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime = {
        offload.enable = true;
        # Make sure to use the correct Bus ID values for your system!
        nvidiaBusId = "PCI:5:0:0";
        amdgpuBusId = "PCI:1:0:0";
      };
    };
  };

  programs = {
    dconf.enable = true;

    hyprland = {
      settings = {
        env = [
          "WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
        ];
      };
      extraConfig = ''
        # Monitor settings
        monitor=eDP-1,1920x1080,0x1080,1
        monitor=HDMI-A-1,1920x1080,0x0,1
      '';
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";
}
