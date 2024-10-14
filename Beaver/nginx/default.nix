{ pkgs, config, ... }:
let
  EMAIL = builtins.readFile config.sops.secrets.EMAIL.path;
in
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

        "planka.justalternate.fr" = {
          enableACME = true;
          forceSSL = true;
          listen = [
            { addr = "0.0.0.0"; port = 80; }
            { addr = "0.0.0.0"; port = 8443; ssl = true; }
          ];

          locations."/" = {
            proxyPass = "http://127.0.0.1:3000";
            proxyWebsockets = true; # needed if you need to use WebSocket
            extraConfig =
              # required when the target is also TLS server with multiple hosts
              "proxy_ssl_server_name on;" +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;"
            ;
          };
        };

        "mail.justalternate.fr" = {
          enableACME = true;
          forceSSL = true;
          listen = [
            { addr = "0.0.0.0"; port = 80; }
            { addr = "0.0.0.0"; port = 995; }
            { addr = "0.0.0.0"; port = 8443; ssl = true; }
          ];
        };

        "tianji.justalternate.fr" = {
          enableACME = true;
          forceSSL = true;
          listen = [
            { addr = "0.0.0.0"; port = 80; }
            { addr = "0.0.0.0"; port = 8443; ssl = true; }
          ];
          locations."/" = {
            proxyPass = "http://127.0.0.1:12345";
            proxyWebsockets = true; # needed if you need to use WebSocket
            extraConfig =
              # required when the target is also TLS server with multiple hosts
              "proxy_ssl_server_name on;" +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;"
            ;
          };
        };

        "cloud.justalternate.fr" = {
          enableACME = true;
          forceSSL = true;
          listen = [
            { addr = "0.0.0.0"; port = 80; }
            { addr = "0.0.0.0"; port = 8443; ssl = true; }
          ];
          locations."/" = {
            proxyPass = "http://127.0.0.1:8080";
            proxyWebsockets = true; # needed if you need to use WebSocket
            extraConfig =
              # required when the target is also TLS server with multiple hosts
              "proxy_ssl_server_name on;" +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;"
            ;
          };
        };
        "hauk.justalternate.fr" = {
          enableACME = true;
          forceSSL = true;
          listen = [
            { addr = "0.0.0.0"; port = 80; }
            { addr = "0.0.0.0"; port = 8443; ssl = true; }
          ];
          locations."/" = {
            proxyPass = "http://127.0.0.1:1212";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_pass_header Authorization;

              add_header Referrer-Policy same-origin always;
              add_header X-Frame-Options DENY always;
              add_header X-Content-Type-Options nosniff always;
              add_header X-XSS-Protection "1; mode=block" always;
              add_header X-Robots-Tag "noindex, nofollow" always;

              location ^~ /.well-known/acme-challenge/ {
                # Serve ACME challenge over HTTP without redirect
                default_type "text/plain";
                root /var/lib/acme/acme-challenge;
              }
            '';
          };
        };
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = EMAIL;
  };
}
