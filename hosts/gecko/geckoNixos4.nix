{ modulesPath, ... }:
{
  imports = [
    ./default.nix
    ./hardware-pi3b+.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "geckoNixos4";
}
