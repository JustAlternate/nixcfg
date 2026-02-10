{ config, pkgs, ... }:
{
  services = {
    open-webui = {
      enable = false;
      package = pkgs.unstable.open-webui;
      port = 3040;
      host = "127.0.0.1";
      openFirewall = false;
      environmentFile = "/run/secrets/OPENWEBUI/ENV";
    };

    nginx.virtualHosts."ai.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3040";
        proxyWebsockets = true;
      };
    };
  };

  systemd = {
    services = {
      open-webui = {
        wants = [ "nginx.service" ];
        after = [ "nginx.service" ];
        bindsTo = [ "nginx.service" ];
      };
    };
  };
}
