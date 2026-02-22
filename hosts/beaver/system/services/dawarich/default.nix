{ config, ... }:
{
  services.dawarich = {
    enable = true;
    localDomain = "geo.justalternate.com";
    webPort = 3001;
    environment = {
      OIDC_ENABLED = "true";
      OIDC_NAME = "Keycloak";
      OIDC_ISSUER = "https://auth.justalternate.com/realms/sso";
      OIDC_CLIENT_ID = "dawarich";
      OIDC_REDIRECT_URI = "https://geo.justalternate.com/users/auth/openid_connect/callback";
    };
    extraEnvFiles = [ config.sops.secrets."SSO/DAWARICH_CLIENT_SECRET".path ];
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
