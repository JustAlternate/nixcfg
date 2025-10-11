_: {
  services.nginx.virtualHosts."vpn.justalternate.com" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/api/" = {
        proxyPass = "http://127.0.0.1:3030";
        recommendedProxySettings = true;
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header Connection "";
          proxy_read_timeout 500s;
          proxy_connect_timeout 500s;
          send_timeout 500s;
        '';
      };
      "/" = {
        proxyPass = "http://127.0.0.1:3030/front/";
        recommendedProxySettings = true;
      };
    };
  };
}
