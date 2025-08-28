_: {
  # imports = [ ./docker-compose.nix ];

  services = {
    nginx.virtualHosts."ai.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3040";
        proxyWebsockets = true; # needed if you need to use WebSocket
      };
    };
    nginx.virtualHosts."monitor.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7878";
        proxyWebsockets = true; # needed if you need to use WebSocket
      };
    };
  };
}
