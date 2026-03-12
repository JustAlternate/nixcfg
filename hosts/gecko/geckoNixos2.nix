{ modulesPath, ... }:
{
  imports = [
    ./default.nix
    ./hardware-pi4.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "geckoNixos2";

  # Static IP configuration
  networking.useDHCP = false;
  networking.interfaces.end0 = {
    ipv4.addresses = [
      {
        address = "192.168.1.12";
        prefixLength = 24;
      }
    ];
    ipv4.routes = [
      {
        address = "0.0.0.0";
        prefixLength = 0;
        via = "192.168.1.1";
      }
    ];
  };
}
