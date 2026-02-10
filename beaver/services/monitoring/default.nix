{ config, lib, ... }:
{
  services = {
    promtail = {
      enable = true;
      configuration = {
        server = {
          log_level = "warn";
          http_listen_port = 9003;
          grpc_listen_port = 0;
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
        clients = [
          {
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
          }
        ];
        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = "beaver";
              };
            };
            relabel_configs = [
              {
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }
            ];
            pipeline_stages = [
              {
                drop = {
                  source = "message";
                  expression = ".*(open\\(\\).*).*";
                };
              }
              {
                drop = {
                  source = "message";
                  expression = ".*SSL_read\\(\\) failed.*";
                };
              }
            ];
          }
        ];
      };
    };

    loki = {
      enable = true;
      configuration = {
        server.http_listen_port = 9004;
        auth_enabled = false;

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = {
                store = "inmemory";
              };
              replication_factor = 1;
            };
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
        };

        schema_config = {
          configs = [
            {
              from = "2024-04-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          tsdb_shipper = {
            active_index_directory = "/var/lib/loki/tsdb-index";
            cache_location = "/var/lib/loki/tsdb-cache";
            cache_ttl = "24h";
          };

          filesystem = {
            directory = "/var/lib/loki/chunks";
          };
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
          max_query_lookback = "168h";
          retention_period = "168h";
        };

        compactor = {
          working_directory = "/var/lib/loki";
          compactor_ring = {
            kvstore = {
              store = "inmemory";
            };
          };
        };
      };

    };
    grafana = {
      enable = true;
      settings = {
        analytics.reporting_enabled = false;
        auth = {
          disable_login_form = true;
        };
        server = {
          http_addr = "127.0.0.1";
          http_port = 3060;
          domain = "monitoring.justalternate.com";
          serve_from_sub_path = true;
          root_url = "https://monitoring.justalternate.com";
        };
        "auth.generic_oauth" = lib.mkForce {
          enabled = true;
          name = "Keycloak-OAuth";
          allow_sign_up = true;
          client_id = "grafana";
          client_secret = builtins.readFile config.sops.secrets."SSO/GRAFANA_CLIENT_SECRET".path;
          auth_url = "https://auth.justalternate.com/realms/sso/protocol/openid-connect/auth";
          token_url = "https://auth.justalternate.com/realms/sso/protocol/openid-connect/token";
          role_attribute_path = "\"'Admin'\"";
          scopes = "openid email profile";
        };
        users = {
          allow_sign_up = false;
        };
        security.disable_initial_admin_creation = true;
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Loki";
            type = "loki";
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
            isDefault = false;
          }
        ];
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
          listenAddress = "127.0.0.1";
        };
      };
      globalConfig = {
        scrape_interval = "60s";
        evaluation_interval = "60s";
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
          job_name = "minecraft";
          static_configs = [
            {
              targets = [ "localhost:9940" ];
              labels = {
                server_name = "polytech";
              };
            }
          ];
        }
      ];
    };
  };

  services.nginx.virtualHosts."monitoring.justalternate.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3060";
      recommendedProxySettings = true;
    };
  };
}
