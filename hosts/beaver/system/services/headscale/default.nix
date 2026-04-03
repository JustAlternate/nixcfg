{ config, ... }:
{
  services = {
    headscale = {
      enable = true;
      port = 4004;
      address = "0.0.0.0";
      settings = {
        server_url = "https://headscale.justalternate.com";
        dns.base_domain = "dns.justalternate.com";
        dns.magic_dns = true;
        dns.nameservers.global = [
          "86.54.11.13" # dns4eu
          "1.1.1.1" # cloudflare fallback
        ];
      };
    };

    nginx.virtualHosts."headscale.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:4004";
        proxyWebsockets = true;
      };
    };
  };
}
