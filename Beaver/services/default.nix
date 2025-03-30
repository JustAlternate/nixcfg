_: {
  imports = [
    ./nginx # Web server, reverse proxy
    ./planka # selfhosted Kanban
    ./vaultwarden
    ./openwebui # My personal llm ui backed by together ai for the inference API
    ./owncloud # selhosted google drive
    ./mail
    ./minecraft
    ./monitoring
    ./action-runner
    ./JustVPN
    ./gh-explorer
  ];

  services.nginx.virtualHosts = {
    "pareto.justalternate.com" = {
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
        proxyPass = "http://127.0.0.1:3939";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;"
          +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;";
      };
    };
  };

}
