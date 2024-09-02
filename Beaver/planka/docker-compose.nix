# Auto-generated using compose2nix v0.2.3-pre.
{ pkgs, lib, config, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."planka-planka" = {
    image = "ghcr.io/plankanban/planka:latest";
    environment = {
      "BASE_URL" = "https://planka.justalternate.fr";
      "DATABASE_URL" = "postgresql://postgres@postgres/planka";
      "SECRET_KEY" = "cat /run/secrets/PLANKA/SECRET_KEY";
    };
    volumes = [
      "planka_attachments:/app/private/attachments:rw"
      "planka_project-background-images:/app/public/project-background-images:rw"
      "planka_user-avatars:/app/public/user-avatars:rw"
    ];
    ports = [
      "3000:1337/tcp"
    ];
    dependsOn = [
      "planka-postgres"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=planka"
      "--network=planka_default"
    ];
  };
  systemd.services."docker-planka-planka" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "on-failure";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-network-planka_default.service"
      "docker-volume-planka_attachments.service"
      "docker-volume-planka_project-background-images.service"
      "docker-volume-planka_user-avatars.service"
    ];
    requires = [
      "docker-network-planka_default.service"
      "docker-volume-planka_attachments.service"
      "docker-volume-planka_project-background-images.service"
      "docker-volume-planka_user-avatars.service"
    ];
    partOf = [
      "docker-compose-planka-root.target"
    ];
    wantedBy = [
      "docker-compose-planka-root.target"
    ];
  };
  virtualisation.oci-containers.containers."planka-postgres" = {
    image = "postgres:14-alpine";
    environment = {
      "POSTGRES_DB" = "planka";
      "POSTGRES_HOST_AUTH_METHOD" = "trust";
    };
    volumes = [
      "planka_db-data:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready -U postgres -d planka"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-timeout=5s"
      "--network-alias=postgres"
      "--network=planka_default"
    ];
  };
  systemd.services."docker-planka-postgres" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "on-failure";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-network-planka_default.service"
      "docker-volume-planka_db-data.service"
    ];
    requires = [
      "docker-network-planka_default.service"
      "docker-volume-planka_db-data.service"
    ];
    partOf = [
      "docker-compose-planka-root.target"
    ];
    wantedBy = [
      "docker-compose-planka-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-planka_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f planka_default";
    };
    script = ''
      docker network inspect planka_default || docker network create planka_default
    '';
    partOf = [ "docker-compose-planka-root.target" ];
    wantedBy = [ "docker-compose-planka-root.target" ];
  };

  # Volumes
  systemd.services."docker-volume-planka_attachments" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect planka_attachments || docker volume create planka_attachments
    '';
    partOf = [ "docker-compose-planka-root.target" ];
    wantedBy = [ "docker-compose-planka-root.target" ];
  };
  systemd.services."docker-volume-planka_db-data" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect planka_db-data || docker volume create planka_db-data
    '';
    partOf = [ "docker-compose-planka-root.target" ];
    wantedBy = [ "docker-compose-planka-root.target" ];
  };
  systemd.services."docker-volume-planka_project-background-images" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect planka_project-background-images || docker volume create planka_project-background-images
    '';
    partOf = [ "docker-compose-planka-root.target" ];
    wantedBy = [ "docker-compose-planka-root.target" ];
  };
  systemd.services."docker-volume-planka_user-avatars" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect planka_user-avatars || docker volume create planka_user-avatars
    '';
    partOf = [ "docker-compose-planka-root.target" ];
    wantedBy = [ "docker-compose-planka-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-planka-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
