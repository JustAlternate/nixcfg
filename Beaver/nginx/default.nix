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
          listen = [{ addr = "127.0.0.1"; port = 8443; ssl = true; }];

          locations."/" = {
            root = "/var/www/justalternate.fr/";
          };
        };

        "planka.justalternate.fr" = {
          enableACME = true;
          forceSSL = true;
          listen = [{ addr = "127.0.0.1"; port = 8443; ssl = true; }];

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

        "tianji.justalternate.fr" = {
          enableACME = true;
          forceSSL = true;
          listen = [{ addr = "127.0.0.1"; port = 8443; ssl = true; }];
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
          listen = [{ addr = "127.0.0.1"; port = 8443; ssl = true; }];
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
        "gps.justalternate.fr" = {
          enableACME = true;
          forceSSL = true;
          listen = [{ addr = "127.0.0.1"; port = 8443; ssl = true; }];
          locations."/" = {
            proxyPass = "http://127.0.0.1:1212";
            extraConfig = ''
              ssl_protocols TLSv1.2 TLSv1.3;
              ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305';
              ssl_session_cache shared:SSL:10m;
              ssl_stapling on;
              ssl_stapling_verify on;

              ssl_ecdh_curve 'secp521r1:secp384r1';
              ssl_prefer_server_ciphers on;
              ssl_session_timeout 10m;
              ssl_session_tickets off;

              proxy_ssl_server_name on;
              proxy_pass_header Authorization;

              add_header Referrer-Policy same-origin always;
              add_header X-Frame-Options DENY always;
              add_header X-Content-Type-Options nosniff always;
              add_header X-XSS-Protection "1; mode=block" always;
              add_header X-Robots-Tag "noindex, nofollow" always;
            '';
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
