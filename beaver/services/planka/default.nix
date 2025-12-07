_: {
  imports = [ ./docker-compose.nix ];

  services.nginx.virtualHosts = {
    "planka.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          "proxy_pass_header Authorization;";
      };
    };
  };
}
