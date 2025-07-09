{ pkgs, ... }:
{
  services = {
    nginx = {
      enable = true;
      package = pkgs.nginxStable.override { openssl = pkgs.libressl; };

      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;

      proxyTimeout = "1000s";

      virtualHosts = {
        "justalternate.com" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            root = "/var/www/justalternate/";
          };
        };
        "justalternate.fr" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            root = "/var/www/justalternate/";
          };
        };
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "loicw@justalternate.fr";
    useRoot = true;
  };
}
