# Auto-generated using compose2nix v0.2.3-pre.
{ pkgs, lib, ... }:
let
  # OWNCLOUD_ADMIN_PASSWORD = builtins.readFile "/run/secrets/OWNCLOUD/OWNCLOUD_ADMIN_PASSWORD";
in
{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."owncloud_mariadb" = {
    image = "mariadb:10.11";
    environment = {
      "MARIADB_AUTO_UPGRADE" = "1";
      "MYSQL_DATABASE" = "owncloud";
      "MYSQL_PASSWORD" = "owncloud";
      "MYSQL_ROOT_PASSWORD" = "owncloud";
      "MYSQL_USER" = "owncloud";
    };
    volumes = [
      "owncloud_mysql:/var/lib/mysql:rw"
    ];
    cmd = [ "--max-allowed-packet=128M" "--innodb-log-file-size=64M" ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"mysqladmin\",\"ping\",\"-u\",\"root\",\"--password=owncloud\"]"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-timeout=5s"
      "--network-alias=mariadb"
      "--network=owncloud_default"
    ];
  };
  systemd.services."docker-owncloud_mariadb" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-network-owncloud_default.service"
      "docker-volume-owncloud_mysql.service"
    ];
    requires = [
      "docker-network-owncloud_default.service"
      "docker-volume-owncloud_mysql.service"
    ];
    partOf = [
      "docker-compose-owncloud-root.target"
    ];
    wantedBy = [
      "docker-compose-owncloud-root.target"
    ];
  };
  virtualisation.oci-containers.containers."owncloud_redis" = {
    image = "redis:6";
    volumes = [
      "owncloud_redis:/data:rw"
    ];
    cmd = [ "--databases" "1" ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"redis-cli\",\"ping\"]"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-timeout=5s"
      "--network-alias=redis"
      "--network=owncloud_default"
    ];
  };
  systemd.services."docker-owncloud_redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-network-owncloud_default.service"
      "docker-volume-owncloud_redis.service"
    ];
    requires = [
      "docker-network-owncloud_default.service"
      "docker-volume-owncloud_redis.service"
    ];
    partOf = [
      "docker-compose-owncloud-root.target"
    ];
    wantedBy = [
      "docker-compose-owncloud-root.target"
    ];
  };
  virtualisation.oci-containers.containers."owncloud_server" = {
    image = "owncloud/server:10.15";
    environment = {
      "OWNCLOUD_ADMIN_PASSWORD" = "temp";
      "OWNCLOUD_ADMIN_USERNAME" = "JustAlternate";
      "OWNCLOUD_DB_HOST" = "mariadb";
      "OWNCLOUD_DB_NAME" = "owncloud";
      "OWNCLOUD_DB_PASSWORD" = "owncloud";
      "OWNCLOUD_DB_TYPE" = "mysql";
      "OWNCLOUD_DB_USERNAME" = "owncloud";
      "OWNCLOUD_DOMAIN" = "cloud.justalternate.fr";
      "OWNCLOUD_MYSQL_UTF8MB4" = "true";
      "OWNCLOUD_REDIS_ENABLED" = "true";
      "OWNCLOUD_REDIS_HOST" = "redis";
      "OWNCLOUD_TRUSTED_DOMAINS" = "cloud.justalternate.fr,justalternate.fr";
    };
    volumes = [
      "owncloud_files:/mnt/data:rw"
    ];
    ports = [
      "8080:8080/tcp"
    ];
    dependsOn = [
      "owncloud_mariadb"
      "owncloud_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"/usr/bin/healthcheck\"]"
      "--health-interval=30s"
      "--health-retries=5"
      "--health-timeout=10s"
      "--network-alias=owncloud"
      "--network=owncloud_default"
    ];
  };
  systemd.services."docker-owncloud_server" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-network-owncloud_default.service"
      "docker-volume-owncloud_files.service"
    ];
    requires = [
      "docker-network-owncloud_default.service"
      "docker-volume-owncloud_files.service"
    ];
    partOf = [
      "docker-compose-owncloud-root.target"
    ];
    wantedBy = [
      "docker-compose-owncloud-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-owncloud_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f owncloud_default";
    };
    script = ''
      docker network inspect owncloud_default || docker network create owncloud_default
    '';
    partOf = [ "docker-compose-owncloud-root.target" ];
    wantedBy = [ "docker-compose-owncloud-root.target" ];
  };

  # Volumes
  systemd.services."docker-volume-owncloud_files" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect owncloud_files || docker volume create owncloud_files --driver=local
    '';
    partOf = [ "docker-compose-owncloud-root.target" ];
    wantedBy = [ "docker-compose-owncloud-root.target" ];
  };
  systemd.services."docker-volume-owncloud_mysql" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect owncloud_mysql || docker volume create owncloud_mysql --driver=local
    '';
    partOf = [ "docker-compose-owncloud-root.target" ];
    wantedBy = [ "docker-compose-owncloud-root.target" ];
  };
  systemd.services."docker-volume-owncloud_redis" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect owncloud_redis || docker volume create owncloud_redis --driver=local
    '';
    partOf = [ "docker-compose-owncloud-root.target" ];
    wantedBy = [ "docker-compose-owncloud-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-owncloud-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
