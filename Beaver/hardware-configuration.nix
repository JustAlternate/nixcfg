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
      device = "/dev/sda1";
      fsType = "ext4";
    };
  };
  nixpkgs.hostPlatform = "aarch64-linux";
}
