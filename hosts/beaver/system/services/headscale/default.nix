{ config, ... }:
{
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 9111;
    settings = {
      server_url = "https://headscale.justalternate.com";
      dns.base_domain = "headscale.justalternate.com";
      log.level = "info";
    };
  };
}
