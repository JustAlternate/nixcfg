{ modulesPath, ... }:
{
  imports = [
    ./geckoNixos2.nix # Select the geckoNixosX to flash here
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  sdImage = {
    compressImage = false;
  };

  image = {
    fileName = "geckoNixosRPI-sd-image.img";
  };
}
