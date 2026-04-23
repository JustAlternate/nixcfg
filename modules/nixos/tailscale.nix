{ config, lib, ... }:
let
  cfg = config.services.tailscale;
in
{
  options.services.tailscale.advertiseExitNode = lib.mkEnableOption "advertise as exit node";

  config = {
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ cfg.interfaceName ];
      allowedUDPPorts = [ cfg.port ];
    };

    boot.kernel.sysctl = lib.mkIf cfg.advertiseExitNode {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."HEADSCALE/PREAUTH_KEY".path;
      extraUpFlags = [
        "--login-server=https://headscale.justalternate.com"
      ]
      ++ lib.optional cfg.advertiseExitNode "--advertise-exit-node";
    };

    systemd.services.tailscaled-autoconnect = {
      after = [ "sops-install-secrets.service" ];
      wants = [ "sops-install-secrets.service" ];
    };
  };
}
