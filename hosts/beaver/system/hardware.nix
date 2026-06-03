{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot = {
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
    };
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "xen_blkfront"
    ];
    initrd.kernelModules = [ "nvme" ];
  };
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/82F0-EC7D";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-uuid/baee471d-b0b8-44ab-93c2-0dfc834895f6";
      fsType = "ext4";
    };
  };

  # Mount 40GB Hetzner volume at /var
  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/6def4e1e-f622-4fcf-8bd3-989f80a2b00f";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
    ];
  };

  # Ensure standard /var directories exist on fresh mount
  systemd.tmpfiles.rules = [
    "d /var/lib 0755 root root -"
    "d /var/log 0755 root root -"
    "d /var/cache 0755 root root -"
    "d /var/tmp 1777 root root -"
    "d /var/run 0755 root root -"
    "d /var/spool 0755 root root -"
    "d /var/mail 0755 root root -"
  ];
  nixpkgs.hostPlatform = "aarch64-linux";
}
