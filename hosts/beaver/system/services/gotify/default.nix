{ config, ... }:
{
  services = {
    gotify = {
      enable = true;
      environmentFiles = [ config.sops.secrets."GOTIFY/ENV".path ];
    };
    nginx.virtualHosts."notif.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3444";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Proto http;
          proxy_connect_timeout   1m;
          proxy_send_timeout      1m;
          proxy_read_timeout      1m;
        '';
      };
    };
  };
}
