{ config, pkgs, ... }:
{
  services = {
    vaultwarden = {
      package = pkgs.unstable.vaultwarden;
      webVaultPackage = pkgs.unstable.vaultwarden.webvault;
      enable = true;
      # backupDir = "/root/backup/vaultwarden";
      config = {
        domain = "https://vaultwarden.justalternate.com";
        rocketAddress = "127.0.0.1";
        rocketPort = 8222;
        signupsAllowed = false; # Never put this to true
        ssoEnabled = true;
        ssoAuthority = "https://auth.justalternate.com/realms/sso";
        ssoScopes = "email profile";
        ssoPkce = true;
        ssoClientId = "vaultwarden";
        ssoSignupsMatchEmail = true;
        ssoOnly = true;
      };
      environmentFile = config.sops.secrets."VAULTWARDEN/ENV".path;
    };

    nginx.virtualHosts."vaultwarden.justalternate.com" = {
      forceSSL = true;
      enableACME = true;
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
