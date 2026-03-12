{ modulesPath, ... }:
  imports = [
    ./default.nix
    ./hardware-pi4.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "geckoNixos2";
}
