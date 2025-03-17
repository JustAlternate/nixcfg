_: {
  imports = [ ./docker-compose.nix ];

  services.nginx.virtualHosts."vpn.justalternate.com" = {
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

    locations = {
      "/" = {
        root = "/var/www/JustVPN/frontend/";
      };
      "/api/health" = {
        proxyPass = "http://127.0.0.1:3030/health";
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;"
          +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;";
      };
      "/api/login" = {
        proxyPass = "http://127.0.0.1:3030/login";
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;"
          +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;";
      };
      "/api/start" = {
        proxyPass = "http://127.0.0.1:3030/start";
        extraConfig = ''
          proxy_ssl_server_name on;
          proxy_pass_header Authorization;
        '';
      };
      "/api/ws" = {
        proxyPass = "http://127.0.0.1:3030/ws";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig = ''
          proxy_read_timeout 500s;
          proxy_send_timeout 600s;
          proxy_connect_timeout 500s;
          send_timeout 500s;
          proxy_ssl_server_name on;
          proxy_pass_header Authorization;
        '';
      };
      "/api/init" = {
        proxyPass = "http://127.0.0.1:3030/init";
        extraConfig = ''
          proxy_read_timeout 500s;
          proxy_send_timeout 500s;
          proxy_connect_timeout 500s;
          send_timeout 500s;
          proxy_pass_header Authorization;
        '';
      };
    };
  };
}
