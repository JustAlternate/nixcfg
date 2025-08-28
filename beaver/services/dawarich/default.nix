_: {
  # imports = [ ./docker-compose.nix ];

  services = {
    nginx.virtualHosts."geo.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";
        proxyWebsockets = true; # needed if you need to use WebSocket
      };
    };
  };
}
