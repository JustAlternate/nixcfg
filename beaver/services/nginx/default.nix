{ pkgs, ... }:
{
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "justalternate.com" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            root = "/var/www/justalternate.com/";
          };
          locations."/homepage" = {
            root = "/var/www/";
          };
        };
      };
      "polynovel.justalternate.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3333";
          extraConfig = "proxy_pass_header Authorization;";
        };
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    useRoot = true;
    defaults = {
      email = "loicw@justalternate.com";
      reloadServices = [
        "nginx.service"
        "dovecot2.service"
        "postfix.service"
      ];
      extraLegoRenewFlags = [ "--no-ari" ];
    };
  };
}
