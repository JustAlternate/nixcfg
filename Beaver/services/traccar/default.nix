_: {
  services.traccar = {
    enable = true;
    settings = {
      databasePassword = "$TRACCAR_PASSWORD";
      "web.enable" = "true";
      "web.port" = "5001";
      "protocol.port" = "5000";
      "server.timeout" = "900";
      "server.statistics" = "";
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
      proxyWebsockets = true; # needed if you need to use WebSocket
      extraConfig =
        # required when the target is also TLS server with multiple hosts
        "proxy_ssl_server_name on;"
        +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;";
    };
  };
}
