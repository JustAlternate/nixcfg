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

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--login-server=https://headscale.justalternate.com"
    ];
    authKeyFile = config.sops.secrets."HEADSCALE/PREAUTH_KEY".path;
  };

  systemd.services.tailscaled-autoconnect = {
    after = [
      "sops-install-secrets.service"
      "tailscaled.service"
    ];
    requires = [ "sops-install-secrets.service" ];
    wants = [ "tailscaled.service" ];
  };
}
