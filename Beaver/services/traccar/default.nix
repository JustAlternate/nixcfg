_: {
  services.traccar = {
    enable = true;
    settings = {
      databasePassword = "$TRACCAR_PASSWORD";
      "web.enable" = "true";
      "web.port" = "5001";
      "web.address" = "127.0.0.1";
      "protocol.port" = "5000";
      "server.timeout" = "900";
    };
    environmentFile = "/run/secrets/TRACCAR";
  };
  services.nginx.virtualHosts."traccar.justalternate.fr" = {
    enableACME = true;
    forceSSL = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 80;
      }
      {
        addr = "0.0.0.0";
        port = 8443;
        ssl = true;
      }
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:5001";
      proxyWebsockets = true;
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
}
