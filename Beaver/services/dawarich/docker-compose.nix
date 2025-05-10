# Auto-generated using compose2nix v0.3.1.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."dawarich_app" = {
    image = "freikin/dawarich:latest";
    environment = {
      "APPLICATION_HOSTS" = "localhost";
      "APPLICATION_PROTOCOL" = "https";
      "DATABASE_HOST" = "dawarich_db";
      "DATABASE_NAME" = "dawarich_development";
      "DATABASE_PASSWORD" = "password";
      "DATABASE_USERNAME" = "postgres";
      "DISTANCE_UNIT" = "km";
      "MIN_MINUTES_SPENT_IN_CITY" = "60";
      "PROMETHEUS_EXPORTER_ENABLED" = "false";
      "PROMETHEUS_EXPORTER_HOST" = "0.0.0.0";
      "PROMETHEUS_EXPORTER_PORT" = "9394";
      "RAILS_ENV" = "development";
      "REDIS_URL" = "redis://dawarich_redis:6379/0";
      "SELF_HOSTED" = "true";
      "TIME_ZONE" = "Europe/Paris";
    };
    volumes = [
      "dawarich_dawarich_public:/var/app/public:rw"
      "dawarich_dawarich_storage:/var/app/storage:rw"
      "dawarich_dawarich_watched:/var/app/tmp/imports/watched:rw"
    ];
    ports = [
      "3000:3000/tcp"
    ];
    cmd = [ "bin/rails" "server" "-p" "3000" "-b" "::" ];
    dependsOn = [
      "dawarich_db"
      "dawarich_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cpus=0.5"
      "--entrypoint=[\"web-entrypoint.sh\"]"
      "--health-cmd=wget -qO - http://127.0.0.1:3000/api/v1/health | grep -q '\"status\"\\s*:\\s*\"ok\"'"
      "--health-interval=10s"
      "--health-retries=30"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--memory=2147483648b"
      "--network-alias=dawarich_app"
      "--network=dawarich_dawarich"
    ];
  };
  systemd.services."docker-dawarich_app" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-dawarich_dawarich.service"
      "docker-volume-dawarich_dawarich_public.service"
      "docker-volume-dawarich_dawarich_storage.service"
      "docker-volume-dawarich_dawarich_watched.service"
    ];
    requires = [
      "docker-network-dawarich_dawarich.service"
      "docker-volume-dawarich_dawarich_public.service"
      "docker-volume-dawarich_dawarich_storage.service"
      "docker-volume-dawarich_dawarich_watched.service"
    ];
    partOf = [
      "docker-compose-dawarich-root.target"
    ];
    wantedBy = [
      "docker-compose-dawarich-root.target"
    ];
  };
  virtualisation.oci-containers.containers."dawarich_db" = {
    image = "postgis/postgis:17-3.5-alpine";
    environment = {
      "POSTGRES_PASSWORD" = "password";
      "POSTGRES_USER" = "postgres";
    };
    volumes = [
      "dawarich_dawarich_db_data:/var/lib/postgresql/data:rw"
      "dawarich_dawarich_shared:/var/shared:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready -U postgres -d dawarich_development"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--network-alias=dawarich_db"
      "--network=dawarich_dawarich"
      "--shm-size=1073741824"
    ];
  };
  systemd.services."docker-dawarich_db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-dawarich_dawarich.service"
      "docker-volume-dawarich_dawarich_db_data.service"
      "docker-volume-dawarich_dawarich_shared.service"
    ];
    requires = [
      "docker-network-dawarich_dawarich.service"
      "docker-volume-dawarich_dawarich_db_data.service"
      "docker-volume-dawarich_dawarich_shared.service"
    ];
    partOf = [
      "docker-compose-dawarich-root.target"
    ];
    wantedBy = [
      "docker-compose-dawarich-root.target"
    ];
  };
  virtualisation.oci-containers.containers."dawarich_redis" = {
    image = "redis:7.0-alpine";
    volumes = [
      "dawarich_dawarich_shared:/data:rw"
    ];
    cmd = [ "redis-server" ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"redis-cli\", \"--raw\", \"incr\", \"ping\"]"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--network-alias=dawarich_redis"
      "--network=dawarich_dawarich"
    ];
  };
  systemd.services."docker-dawarich_redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-dawarich_dawarich.service"
      "docker-volume-dawarich_dawarich_shared.service"
    ];
    requires = [
      "docker-network-dawarich_dawarich.service"
      "docker-volume-dawarich_dawarich_shared.service"
    ];
    partOf = [
      "docker-compose-dawarich-root.target"
    ];
    wantedBy = [
      "docker-compose-dawarich-root.target"
    ];
  };
  virtualisation.oci-containers.containers."dawarich_sidekiq" = {
    image = "freikin/dawarich:latest";
    environment = {
      "APPLICATION_HOSTS" = "localhost";
      "APPLICATION_PROTOCOL" = "https";
      "BACKGROUND_PROCESSING_CONCURRENCY" = "10";
      "DATABASE_HOST" = "dawarich_db";
      "DATABASE_NAME" = "dawarich_development";
      "DATABASE_PASSWORD" = "password";
      "DATABASE_USERNAME" = "postgres";
      "DISTANCE_UNIT" = "km";
      "PROMETHEUS_EXPORTER_ENABLED" = "false";
      "PROMETHEUS_EXPORTER_HOST" = "dawarich_app";
      "PROMETHEUS_EXPORTER_PORT" = "9394";
      "RAILS_ENV" = "development";
      "REDIS_URL" = "redis://dawarich_redis:6379/0";
      "SELF_HOSTED" = "true";
    };
    volumes = [
      "dawarich_dawarich_public:/var/app/public:rw"
      "dawarich_dawarich_storage:/var/app/storage:rw"
      "dawarich_dawarich_watched:/var/app/tmp/imports/watched:rw"
    ];
    cmd = [ "sidekiq" ];
    dependsOn = [
      "dawarich_app"
      "dawarich_db"
      "dawarich_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cpus=0.5"
      "--entrypoint=[\"sidekiq-entrypoint.sh\"]"
      "--health-cmd=bundle exec sidekiqmon processes | grep \${HOSTNAME}"
      "--health-interval=10s"
      "--health-retries=30"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--memory=2147483648b"
      "--network-alias=dawarich_sidekiq"
      "--network=dawarich_dawarich"
    ];
  };
  systemd.services."docker-dawarich_sidekiq" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-dawarich_dawarich.service"
      "docker-volume-dawarich_dawarich_public.service"
      "docker-volume-dawarich_dawarich_storage.service"
      "docker-volume-dawarich_dawarich_watched.service"
    ];
    requires = [
      "docker-network-dawarich_dawarich.service"
      "docker-volume-dawarich_dawarich_public.service"
      "docker-volume-dawarich_dawarich_storage.service"
      "docker-volume-dawarich_dawarich_watched.service"
    ];
    partOf = [
      "docker-compose-dawarich-root.target"
    ];
    wantedBy = [
      "docker-compose-dawarich-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-dawarich_dawarich" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f dawarich_dawarich";
    };
    script = ''
      docker network inspect dawarich_dawarich || docker network create dawarich_dawarich
    '';
    partOf = [ "docker-compose-dawarich-root.target" ];
    wantedBy = [ "docker-compose-dawarich-root.target" ];
  };

  # Volumes
  systemd.services."docker-volume-dawarich_dawarich_db_data" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect dawarich_dawarich_db_data || docker volume create dawarich_dawarich_db_data
    '';
    partOf = [ "docker-compose-dawarich-root.target" ];
    wantedBy = [ "docker-compose-dawarich-root.target" ];
  };
  systemd.services."docker-volume-dawarich_dawarich_public" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect dawarich_dawarich_public || docker volume create dawarich_dawarich_public
    '';
    partOf = [ "docker-compose-dawarich-root.target" ];
    wantedBy = [ "docker-compose-dawarich-root.target" ];
  };
  systemd.services."docker-volume-dawarich_dawarich_shared" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect dawarich_dawarich_shared || docker volume create dawarich_dawarich_shared
    '';
    partOf = [ "docker-compose-dawarich-root.target" ];
    wantedBy = [ "docker-compose-dawarich-root.target" ];
  };
  systemd.services."docker-volume-dawarich_dawarich_storage" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect dawarich_dawarich_storage || docker volume create dawarich_dawarich_storage
    '';
    partOf = [ "docker-compose-dawarich-root.target" ];
    wantedBy = [ "docker-compose-dawarich-root.target" ];
  };
  systemd.services."docker-volume-dawarich_dawarich_watched" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect dawarich_dawarich_watched || docker volume create dawarich_dawarich_watched
    '';
    partOf = [ "docker-compose-dawarich-root.target" ];
    wantedBy = [ "docker-compose-dawarich-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-dawarich-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
