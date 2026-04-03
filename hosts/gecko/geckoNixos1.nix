{
  modulesPath,
  lib,
  config,
  ...
}:
{
  imports = [
    ./default.nix
    ./hardware-pi3b+.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/sops.nix
  ];

  networking = {
    hostName = "geckoNixos1";
    useDHCP = lib.mkForce false;
    nameservers = [ "192.168.1.1" ];
    interfaces.enu1u1 = {
      ipv4.addresses = [
        {
          address = "192.168.1.11";
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
  };
}
