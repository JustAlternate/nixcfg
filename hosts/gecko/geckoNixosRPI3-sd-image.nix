{ modulesPath, ... }:
{
  imports = [
    ./default.nix
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  # Configure SD image
  sdImage = {
    compressImage = false;
    imageName = "geckoNixosRPI3-sd-image.img";
  };

  # Boot configuration for Raspberry Pi
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.grub.enable = false;

  # Kernel parameters for Raspberry Pi 3 B+
  boot.kernelParams = [ "cma=256M" ];
}
