{ config, ... }:
{
  services = {
    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3060;
          domain = "monitoring.justalternate.fr";
          serve_from_sub_path = true;
        };
      };
    };
    prometheus = {
      enable = true;
      port = 9001;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "systemd"
          ];
          port = 9002;
        };
      };
      scrapeConfigs = [
        {
          job_name = "scraper";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
            }
          ];
        }
        {
          job_name = "gh-explorer";
          static_configs = [
            {
              targets = [ "metrics.gh-explorer.com" ];
            }
          ];
          scheme = "https";
          tls_config = {
            insecure_skip_verify = true;
          };
        }
      ];
    };
  };

  services.nginx.virtualHosts."monitoring.justalternate.fr" = {
    enableACME = true;
    forceSSL = true;
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
      proxyPass = "http://127.0.0.1:3060";
      recommendedProxySettings = true;
    };
    locations."/prometheus" = {
      proxyPass = "http://127.0.0.1:9001";
      recommendedProxySettings = true;
    };
  };
}
