{ lib, ... }:
let
  jellyfin-http = 8096;
  jellyfin-https = 8920;
  jellyfin-client-discovery = 7359;
  radarr = 7878;
  sonarr = 8989;
  prowlarr = 9696;
  bazarr = 6767;
  deluge-web = 8112;
  deluge-daemon = 58846;
  deluge-listen = [
    6881
    6891
  ];
in
{
  services = {
    jellyfin = {
      enable = true;
      user = "root";
      group = "media";
    };

    radarr = {
      enable = true;
      user = "root";
      group = "media";
    };

    sonarr = {
      enable = true;
      openFirewall = true;
      user = "root";
      group = "media";
    };

    prowlarr = {
      enable = true;
    };

    bazarr = {
      enable = true;
      listenPort = bazarr;
      user = "root";
      group = "media";
    };

    deluge = {
      enable = true;
      declarative = false;
      openFirewall = true;
      user = "root";
      group = "media";
      authFile = "/home/justalternate/authfile";
      web = {
        enable = true;
        port = deluge-web;
      };
      config = {
        daemon_port = deluge-daemon;
        listen_ports = deluge-listen;

        enabled_plugins = [ "Label" ];

        max_active_limit = -1;
        max_active_downloading = -1;
        max_active_seeding = 10;

        max_download_speed = 20000.0;
        max_upload_speed = 5000.0;

        remove_seed_at_ratio = true;
        stop_seed_ratio = 2.0;

        download_location = "/data/Downloads/Incomplete";
        move_completed = true;
        move_completed_path = "/data/Downloads/Complete";
        copy_torrent_file = true;
        torrentfiles_location = "/data/Downloads/Torrents";
      };
    };
  };

  systemd.services.jellyfin.serviceConfig = {
    DeviceAllow = lib.mkForce "char-drm";
    BindPaths = lib.mkForce "/dev/dri";
    Restart = lib.mkForce "always";
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    jellyfin-http
    jellyfin-https
    radarr
    sonarr
    prowlarr
    bazarr
    deluge-web
  ];

  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ jellyfin-client-discovery ];

  users = {
    groups = {
      media = {
        members = [ "root" ];
      };
    };
  };
}
