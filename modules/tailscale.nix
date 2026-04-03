{ config, ... }:
{
  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."HEADSCALE/PREAUTH_KEY".path;
    extraUpFlags = [
      "--login-server=https://headscale.justalternate.com"
      "--reset"
    ];
  };

  systemd.services.tailscaled-autoconnect = {
    after = [ "sops-install-secrets.service" ];
    wants = [ "sops-install-secrets.service" ];
  };
}
