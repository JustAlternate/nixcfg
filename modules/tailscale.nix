{ config, ... }:
{
  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--login-server=https://headscale.justalternate.com"
    ];
    authKeyFile = config.sops.secrets."HEADSCALE/PREAUTH_KEY".path;
    authKeyParameters.preauthorized = true;
  };
}
