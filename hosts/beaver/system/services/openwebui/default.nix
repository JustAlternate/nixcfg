{ config, pkgs, ... }:
{
  services = {
    open-webui = {
      enable = true;
      port = 3040;
      host = "127.0.0.1";
      openFirewall = false;
      environmentFile = config.sops.secrets."OPENWEBUI/ENV".path;
      environment = {
        WEBUI_CORS_ALLOW_ORIGIN = "https://ai.justalternate.com";
        USER_AGENT = "open-webui/0.10.2 (beaver; justalternate.com)";
      };
      package = pkgs.unstable.open-webui; # unstable: stable 0.9.6 < running 0.10.2, downgrade breaks alembic;
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
        path = [ pkgs.ffmpeg ];
      };
    };
  };
}
