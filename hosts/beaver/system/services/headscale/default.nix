{ config, ... }:
{
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 9111;
    settings = {
      server_url = "https://headscale.justalternate.com";
      dns.base_domain = "dns.justalternate.com";
      dns.nameservers.global = [
        "1.1.1.1"
        "86.54.11.13"
      ];
      log.level = "info";
    };
  };
}
