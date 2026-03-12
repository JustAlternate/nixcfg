{ modulesPath, ... }:
{
  imports = [
    ./default.nix
    ./hardware-pi3b+.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "geckoNixos4";

  # Static IP configuration
  networking.useDHCP = false;
  networking.interfaces.end0 = {
    ipv4.addresses = [
      {
        address = "192.168.1.14";
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
