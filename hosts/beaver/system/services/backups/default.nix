{
  config,
  pkgs,
  ...
}:
{
  programs.ssh.knownHosts = {
    "[u641107.your-storagebox.de]:23" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
    };
  };

  sops = {
    secrets = {
      "RESTIC/PASSWORD" = {
        owner = "root";
        mode = "0400";
      };
      "RESTIC/SFTP_USER" = {
        owner = "root";
        mode = "0400";
      };
      "RESTIC/SFTP_PASSWORD" = {
        owner = "root";
        mode = "0400";
      };
    };
    templates."restic-beaver-env" = {
      path = "/run/restic-beaver-env";
      content = ''
        RESTIC_REPOSITORY=sftp:${config.sops.placeholder."RESTIC/SFTP_USER"}@${config.sops.placeholder."RESTIC/SFTP_USER"}.your-storagebox.de:23/backups/beaver
        RESTIC_PASSWORD=${config.sops.placeholder."RESTIC/PASSWORD"}
        SSHPASS='${config.sops.placeholder."RESTIC/SFTP_PASSWORD"}'
      '';
    };
  };

  services.postgresqlBackup = {
    enable = true;
    databases = [
      "dawarich"
    ];
    location = "/var/backup/postgresql";
    startAt = "daily";
  };

  services.restic.backups = {
    beaver = {
      environmentFile = "/run/restic-beaver-env";
      initialize = true;

      paths = [
        "/var/lib/bitwarden_rs"
        "/var/vmail"
        "/var/dkim"
        "/var/www"
        "/var/lib/headscale"
        "/var/lib/dawarich"
        "/var/lib/rauthy"
        "/var/lib/grafana"
        "/var/lib/postgresql"
        "/var/backup/postgresql"
        "/var/lib/acme"
        "/var/lib/tailscale"
        "/var/lib/private/goatcounter"
        "/var/lib/private/gotify-server"
      ];

      exclude = [
        "*.log"
        ".cache"
        "/var/lib/headscale/.cache"
      ];

      timerConfig = {
        OnCalendar = "Mon,Thu *-*-* 03:00:00";
        Persistent = true;
        RandomizedDelaySec = "2h";
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];

      checkOpts = [
        "--read-data-subset=1%"
      ];

      extraOptions = [
        "sftp.command='${pkgs.sshpass}/bin/sshpass -e ssh -p 23 -o StrictHostKeyChecking=yes u641107@u641107.your-storagebox.de -s sftp'"
      ];
    };
  };

  systemd.services.restic-backups-beaver = {
    after = [
      "postgresqlBackup-dawarich.service"
    ];
  };
}
