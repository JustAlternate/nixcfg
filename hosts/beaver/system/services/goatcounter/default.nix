_: {
  services.goatcounter = {
    enable = true;
    # behind nginx: -tls proxy makes goatcounter trust X-Forwarded-For
    # (recommendedProxySettings provides it) so visitor IPs are recorded.
    proxy = true;
    port = 3041;
  };
  services.nginx.virtualHosts = {
    "analytics.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3041";
        extraConfig = "proxy_pass_header Authorization;";
      };
    };
  };
}
