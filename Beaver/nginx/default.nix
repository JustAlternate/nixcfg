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

      virtualHosts = {
        "justalternate.fr" = {
          enableACME = true;
          forceSSL = true;
          listen = [
            { addr = "0.0.0.0"; port = 80; }
            { addr = "0.0.0.0"; port = 8443; ssl = true; }
          ];
          locations."/" = {
            root = "/var/www/justalternate.fr/";
          };
        };
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "loicw@justalternate.fr";
  };
}
