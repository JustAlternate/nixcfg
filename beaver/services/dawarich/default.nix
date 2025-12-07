_: {
  imports = [
    ./definition.nix
  ];
  services.dawarich = {
    enable = true;
    localDomain = "geo.justalternate.com";
    webPort = 3001;
  };

  services.nginx.virtualHosts = {
    "geo.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";
        proxyWebsockets = true;
        extraConfig = "proxy_pass_header Authorization;";
      };
    };
  };
}
