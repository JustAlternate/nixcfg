_: {
  services = {
    keycloak = {
      enable = true;
      database.passwordFile = "/run/secrets/PASSWORD";
      settings = {
        hostname = "https://auth.justalternate.com";
        hostname-backchannel-dynamic = true; # Allow application hosted on the same local network as keycloak to enable internal communication
        http-enabled = true; # https handled by our reverse proxy
        http-port = 3127;
        proxy-headers = "xforwarded";
      };
    };
    nginx.virtualHosts."auth.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3127";
        proxyWebsockets = true;
      };
    };
  };
}
