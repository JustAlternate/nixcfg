_: {
  services = {
    vaultwarden = {
      enable = true;
      # backupDir = "/root/backup/vaultwarden";
      config = {
        domain = "https://vaultwarden.justalternate.fr";
        rocketAddress = "127.0.0.1";
        rocketPort = 8222;
        signupsAllowed = false; # Never put this to true
      };
      environmentFile = "/run/secrets/VAULTWARDEN/ENV";
    };

    nginx.virtualHosts."vaultwarden.justalternate.fr" = {
      forceSSL = true;
      enableACME = true;
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
        proxyPass = "http://127.0.0.1:8222";
        proxyWebsockets = true;
      };
      extraConfig = ''
        proxy_read_timeout 90;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Frame-Options SAMEORIGIN;
      '';
    };
  };

  systemd = {
    services = {
      vaultwarden = {
        wants = [ "nginx.service" ];
        after = [ "nginx.service" ];
        bindsTo = [ "nginx.service" ];
      };
    };
  };
}
