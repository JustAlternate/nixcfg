_: {
  services.nginx.virtualHosts."explorer.justalternate.com" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = {
        root = "/var/www/gh-explorer/";
        extraConfig = "try_files $uri $uri/ =404;";
      };
      "/api/v1/" = {
        proxyPass = "http://127.0.0.1:3031";
        proxyWebsockets = true;
      };
    };
  };
  system.activationScripts.webDirectories = {
    text = ''
      mkdir -p /var/www/gh-explorer/
      mkdir -p /var/www/gh-explorer/backend/
      chmod 755 /var/www/gh-explorer/
      chown -R nginx:nginx /var/www/gh-explorer/
    '';
    deps = [ ];
  };
}
