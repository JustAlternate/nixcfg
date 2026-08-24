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
    ./llm-env.nix
  ];

  machineName = "swordfish";
  networking.hostName = "swordfish";

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
    ckb-next = {
      enable = true;
      package = pkgs.ckb-next.overrideAttrs (old: {
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DUSE_DBUS_MENU=0" ];
      });
    };
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };

  # Monitor/workspace/exec-once settings live in profiles/nixos/desktop/hyprland.conf

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";
}
