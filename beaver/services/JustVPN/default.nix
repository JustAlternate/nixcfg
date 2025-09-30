_: {
  # imports = [ ./docker-compose.nix ];

  services.nginx.virtualHosts."vpn.justalternate.com" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:3030/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_read_timeout 500s;
          proxy_connect_timeout 500s;
          send_timeout 500s;
        '';
      };
    };
  };
}
