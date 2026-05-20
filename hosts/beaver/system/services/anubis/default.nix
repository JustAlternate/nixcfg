_: {
  services.anubis.instances.default.settings = {
    TARGET = "http://127.0.0.1:8081";
    BIND = "127.0.0.1:8923";
    BIND_NETWORK = "tcp";
    METRICS_BIND = "127.0.0.1:9090";
    METRICS_BIND_NETWORK = "tcp";
    DIFFICULTY = 5;
    SERVE_ROBOTS_TXT = true;
    OG_PASSTHROUGH = true;
  };

  services.nginx.virtualHosts."internal-static" = {
    listen = [
      {
        addr = "127.0.0.1";
        port = 8081;
      }
    ];
    locations."/" = {
      root = "/var/www/justalternate.com/";
    };
    locations."/homepage" = {
      root = "/var/www/";
    };
  };
}
