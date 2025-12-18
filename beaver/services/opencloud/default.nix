{ config, ... }:
{
  services = {
    opencloud = {
      enable = true;
      user = "JustAlternate";
      url = "https://cloud.justalternate.com";
      stateDir = "/var/lib/opencloud/";
      port = 9200;
      environmentFile = config.sops.secrets."OPENCLOUD/ENV".path;
    };

    nginx.virtualHosts."cloud.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9200";
        proxyWebsockets = true;
      };
    };
  };
}
