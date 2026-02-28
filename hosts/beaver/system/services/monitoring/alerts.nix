# Grafana alerting rules
# Each group contains related alerts with their conditions, queries, and metadata

{
  # Service availability monitoring - uptime, response time, SSL expiry
  serviceAvailability = {
    orgId = 1;
    name = "service_availability";
    folder = "Alerts";
    interval = "60s";
    rules = [
      {
        uid = "service-down";
        title = "Service Down";
        condition = "C";
        data = [
          {
            refId = "A";
            relativeTimeRange = {
              from = 300;
              to = 0;
            };
            datasourceUid = "PBFA97CFB590B2093";
            model = {
              expr = "count by (instance) (probe_success == 0) > 0";
              refId = "A";
            };
          }
          {
            refId = "B";
            datasourceUid = "__expr__";
            model = {
              type = "reduce";
              expression = "A";
              reducer = "last";
              refId = "B";
            };
          }
          {
            refId = "C";
            datasourceUid = "__expr__";
            model = {
              type = "threshold";
              expression = "B";
              refId = "C";
              conditions = [
                {
                  evaluator = {
                    type = "gt";
                    params = [ 0 ];
                  };
                }
              ];
            };
          }
        ];
        noDataState = "OK";
        execErrState = "Error";
        for = "1m";
        annotations = {
          summary = "Service {{ $labels.instance }} is down";
          description = "The service has been down for more than 1 minute";
        };
        labels = {
          severity = "critical";
        };
      }
      {
        uid = "slow-response";
        title = "Slow Service Response";
        condition = "C";
        data = [
          {
            refId = "A";
            relativeTimeRange = {
              from = 300;
              to = 0;
            };
            datasourceUid = "PBFA97CFB590B2093";
            model = {
              expr = "avg by (instance) (probe_duration_seconds) > 5";
              refId = "A";
            };
          }
          {
            refId = "B";
            datasourceUid = "__expr__";
            model = {
              type = "reduce";
              expression = "A";
              reducer = "last";
              refId = "B";
            };
          }
          {
            refId = "C";
            datasourceUid = "__expr__";
            model = {
              type = "threshold";
              expression = "B";
              refId = "C";
              conditions = [
                {
                  evaluator = {
                    type = "gt";
                    params = [ 0 ];
                  };
                }
              ];
            };
          }
        ];
        noDataState = "OK";
        execErrState = "Error";
        for = "1m";
        annotations = {
          summary = "Service {{ $labels.instance }} is responding slowly (>5s)";
        };
        labels = {
          severity = "warning";
        };
      }
      {
        uid = "ssl-expiry";
        title = "SSL Certificate Expiring Soon";
        condition = "C";
        data = [
          {
            refId = "A";
            relativeTimeRange = {
              from = 300;
              to = 0;
            };
            datasourceUid = "PBFA97CFB590B2093";
            model = {
              expr = "min by (instance) (probe_ssl_earliest_cert_expiry - time()) < 604800";
              refId = "A";
            };
          }
          {
            refId = "B";
            datasourceUid = "__expr__";
            model = {
              type = "reduce";
              expression = "A";
              reducer = "last";
              refId = "B";
            };
          }
          {
            refId = "C";
            datasourceUid = "__expr__";
            model = {
              type = "threshold";
              expression = "B";
              refId = "C";
              conditions = [
                {
                  evaluator = {
                    type = "gt";
                    params = [ 0 ];
                  };
                }
              ];
            };
          }
        ];
        noDataState = "OK";
        execErrState = "Error";
        for = "1m";
        annotations = {
          summary = "SSL certificate for {{ $labels.instance }} expires in less than 7 days";
        };
        labels = {
          severity = "warning";
        };
      }
    ];
  };

  # System health monitoring - CPU, memory, disk usage
  systemHealth = {
    orgId = 1;
    name = "system_health";
    folder = "Alerts";
    interval = "60s";
    rules = [
      {
        uid = "high-cpu";
        title = "High CPU Usage";
        condition = "C";
        data = [
          {
            refId = "A";
            relativeTimeRange = {
              from = 300;
              to = 0;
            };
            datasourceUid = "PBFA97CFB590B2093";
            model = {
              expr = "100 - (avg by (instance) (irate(node_cpu_seconds_total{mode='idle'}[5m])) * 100)";
              refId = "A";
            };
          }
          {
            refId = "B";
            datasourceUid = "__expr__";
            model = {
              type = "reduce";
              expression = "A";
              reducer = "last";
              refId = "B";
            };
          }
          {
            refId = "C";
            datasourceUid = "__expr__";
            model = {
              type = "threshold";
              expression = "B";
              refId = "C";
              conditions = [
                {
                  evaluator = {
                    type = "gt";
                    params = [ 80 ];
                  };
                }
              ];
            };
          }
        ];
        noDataState = "OK";
        execErrState = "Error";
        for = "5m";
        annotations = {
          summary = "CPU usage is above 80% on {{ $labels.instance }}";
        };
        labels = {
          severity = "warning";
        };
      }
      {
        uid = "high-memory";
        title = "High Memory Usage";
        condition = "C";
        data = [
          {
            refId = "A";
            relativeTimeRange = {
              from = 300;
              to = 0;
            };
            datasourceUid = "PBFA97CFB590B2093";
            model = {
              expr = "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100";
              refId = "A";
            };
          }
          {
            refId = "B";
            datasourceUid = "__expr__";
            model = {
              type = "reduce";
              expression = "A";
              reducer = "last";
              refId = "B";
            };
          }
          {
            refId = "C";
            datasourceUid = "__expr__";
            model = {
              type = "threshold";
              expression = "B";
              refId = "C";
              conditions = [
                {
                  evaluator = {
                    type = "gt";
                    params = [ 85 ];
                  };
                }
              ];
            };
          }
        ];
        noDataState = "OK";
        execErrState = "Error";
        for = "5m";
        annotations = {
          summary = "Memory usage is above 85% on {{ $labels.instance }}";
        };
        labels = {
          severity = "warning";
        };
      }
      {
        uid = "root-disk-full";
        title = "Root Filesystem Full";
        condition = "C";
        data = [
          {
            refId = "A";
            relativeTimeRange = {
              from = 300;
              to = 0;
            };
            datasourceUid = "PBFA97CFB590B2093";
            model = {
              expr = ''(node_filesystem_size_bytes{mountpoint="/"} - node_filesystem_avail_bytes{mountpoint="/"}) / node_filesystem_size_bytes{mountpoint="/"} * 100'';
              refId = "A";
            };
          }
          {
            refId = "B";
            datasourceUid = "__expr__";
            model = {
              type = "reduce";
              expression = "A";
              reducer = "last";
              refId = "B";
            };
          }
          {
            refId = "C";
            datasourceUid = "__expr__";
            model = {
              type = "threshold";
              expression = "B";
              refId = "C";
              conditions = [
                {
                  evaluator = {
                    type = "gt";
                    params = [ 90 ];
                  };
                }
              ];
            };
          }
        ];
        noDataState = "OK";
        execErrState = "Error";
        for = "5m";
        annotations = {
          summary = "Root filesystem usage is above 90% on {{ $labels.instance }}";
        };
        labels = {
          severity = "critical";
        };
      }
      {
        uid = "var-disk-full";
        title = "Var Filesystem Full";
        condition = "C";
        data = [
          {
            refId = "A";
            relativeTimeRange = {
              from = 300;
              to = 0;
            };
            datasourceUid = "PBFA97CFB590B2093";
            model = {
              expr = ''(node_filesystem_size_bytes{mountpoint="/var"} - node_filesystem_avail_bytes{mountpoint="/var"}) / node_filesystem_size_bytes{mountpoint="/var"} * 100'';
              refId = "A";
            };
          }
          {
            refId = "B";
            datasourceUid = "__expr__";
            model = {
              type = "reduce";
              expression = "A";
              reducer = "last";
              refId = "B";
            };
          }
          {
            refId = "C";
            datasourceUid = "__expr__";
            model = {
              type = "threshold";
              expression = "B";
              refId = "C";
              conditions = [
                {
                  evaluator = {
                    type = "gt";
                    params = [ 90 ];
                  };
                }
              ];
            };
          }
        ];
        noDataState = "OK";
        execErrState = "Error";
        for = "5m";
        annotations = {
          summary = "/var filesystem usage is above 90% on {{ $labels.instance }}";
        };
        labels = {
          severity = "critical";
        };
      }
      {
        uid = "disk-inodes";
        title = "Low Inodes Available";
        condition = "C";
        data = [
          {
            refId = "A";
            relativeTimeRange = {
              from = 300;
              to = 0;
            };
            datasourceUid = "PBFA97CFB590B2093";
            model = {
              expr = "1 - (node_filesystem_files_free{mountpoint=\"/\"} / node_filesystem_files{mountpoint=\"/\"})";
              refId = "A";
            };
          }
          {
            refId = "B";
            datasourceUid = "__expr__";
            model = {
              type = "reduce";
              expression = "A";
              reducer = "last";
              refId = "B";
            };
          }
          {
            refId = "C";
            datasourceUid = "__expr__";
            model = {
              type = "threshold";
              expression = "B";
              refId = "C";
              conditions = [
                {
                  evaluator = {
                    type = "gt";
                    params = [ 90 ];
                  };
                }
              ];
            };
          }
        ];
        noDataState = "OK";
        execErrState = "Error";
        for = "5m";
        annotations = {
          summary = "Less than 10% inodes available on {{ $labels.instance }}";
        };
        labels = {
          severity = "critical";
        };
      }
    ];
  };

  # Log-based alerts - error spikes, service crashes
  logAlerts = {
    orgId = 1;
    name = "log_alerts";
    folder = "Alerts";
    interval = "60s";
    rules = [
      {
        uid = "error-spike";
        title = "Error Log Spike";
        condition = "C";
        data = [
          {
            refId = "A";
            relativeTimeRange = {
              from = 300;
              to = 0;
            };
            datasourceUid = "P8E80F9AEF21F6940";
            model = {
              expr = ''sum(rate({host="beaver"} | logfmt | label_format level=detected_level | level =~ `error` |~ `(?i).*.*` [5m])) > 10'';
              refId = "A";
            };
          }
          {
            refId = "B";
            datasourceUid = "__expr__";
            model = {
              type = "reduce";
              expression = "A";
              reducer = "last";
              refId = "B";
            };
          }
          {
            refId = "C";
            datasourceUid = "__expr__";
            model = {
              type = "threshold";
              expression = "B";
              refId = "C";
              conditions = [
                {
                  evaluator = {
                    type = "gt";
                    params = [ 0 ];
                  };
                }
              ];
            };
          }
        ];
        noDataState = "OK";
        execErrState = "Error";
        for = "1m";
        annotations = {
          summary = "Error rate is above 20 errors per second";
        };
        labels = {
          severity = "warning";
        };
      }
      {
        uid = "service-crash";
        title = "Service Crash Detected";
        condition = "C";
        data = [
          {
            refId = "A";
            relativeTimeRange = {
              from = 300;
              to = 0;
            };
            datasourceUid = "P8E80F9AEF21F6940";
            model = {
              expr = ''sum(rate({host="beaver", unit!~"loki.service|grafana\\.service"} |~ `Failed to start|entered failed state` [5m]))'';
              refId = "A";
            };
          }
          {
            refId = "B";
            datasourceUid = "__expr__";
            model = {
              type = "reduce";
              expression = "A";
              reducer = "last";
              refId = "B";
            };
          }
          {
            refId = "C";
            datasourceUid = "__expr__";
            model = {
              type = "threshold";
              expression = "B";
              refId = "C";
              conditions = [
                {
                  evaluator = {
                    type = "gt";
                    params = [ 0 ];
                  };
                }
              ];
            };
          }
        ];
        noDataState = "OK";
        execErrState = "Error";
        for = "1m";
        annotations = {
          summary = "A systemd service has crashed or failed to start";
        };
        labels = {
          severity = "critical";
        };
      }
    ];
  };
}
