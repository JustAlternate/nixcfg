{ config, pkgs, ... }:
{
  services.dawarich = {
    enable = true;
    package = pkgs.unstable.dawarich; # pin reason: stable 1.7.5 << running 1.10.3, Rails DB migrations do not roll back
    localDomain = "geo.justalternate.com";
    webPort = 3001;
    environment = {
      OIDC_ENABLED = "true";
      OIDC_NAME = "Rauthy";
      OIDC_ISSUER = "https://auth.justalternate.com/auth/v1/";
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
