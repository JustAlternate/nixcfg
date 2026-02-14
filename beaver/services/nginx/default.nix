{ ... }:
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
        "polynovel.justalternate.com" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:3333";
            proxyWebsockets = true;
            extraConfig = ''
              							proxy_set_header Host $host;
              							proxy_set_header X-Real-IP $remote_addr;
              							proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              							proxy_set_header X-Forwarded-Proto $scheme;
              							proxy_pass_header Authorization;
              						'';
          };
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
      extraLegoRenewFlags = [ "--ari-disable" ];
    };
  };
}
