_: {
  # imports = [ ./docker-compose.nix ];

  services = {
    nginx.virtualHosts."geo.justalternate.com" = {
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
        proxyPass = "http://127.0.0.1:3001";
        proxyWebsockets = true; # needed if you need to use WebSocket
      };
    };
  };
}
