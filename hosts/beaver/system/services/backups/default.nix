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
        RESTIC_REPOSITORY=sftp:${config.sops.placeholder."RESTIC/SFTP_USER"}@${
          config.sops.placeholder."RESTIC/SFTP_USER"
        }.your-storagebox.de:23/backups/beaver
        RESTIC_PASSWORD=${config.sops.placeholder."RESTIC/PASSWORD"}
        SSHPASS='${config.sops.placeholder."RESTIC/SFTP_PASSWORD"}'
      '';
    };
  };

  services.postgresqlBackup = {
    enable = true;
    databases = [
      "dawarich"
      "sharry"
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
        "/var/lib/private/open-webui/data"
        "/var/backup/sqlite"
        "/root/polynovel"
        "/root/nixcfg"
        "/root/.config/opencode"
        "/root/.local/share/opencode/storage"
        "/root/.local/share/opencode/snapshot"
        "/root/.config/sops/age/keys.txt"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ecdsa_key"
        "/etc/ssh/ssh_host_ecdsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];

      exclude = [
        "*.log"
        ".cache"
        "/var/lib/headscale/.cache"
        "/root/.config/opencode/node_modules"
        "/var/lib/private/open-webui/data/cache"
      ];

      backupPrepareCommand = ''
        #!${pkgs.runtimeShell}
        set -euo pipefail
        umask 077
        install -d -m 0700 /var/backup/sqlite
        tmp=""
        trap 'if [ -n "$tmp" ]; then rm -f -- "$tmp" "$tmp-wal" "$tmp-shm"; fi' EXIT

        backup_sqlite() {
          local source="$1" name="$2"
          tmp=$(mktemp /var/backup/sqlite/.backup.XXXXXXXX)
          ${pkgs.sqlite}/bin/sqlite3 -readonly -cmd '.timeout 15000' "$source" ".backup '$tmp'"
          if [ "$(${pkgs.sqlite}/bin/sqlite3 "$tmp" 'PRAGMA journal_mode=DELETE;')" != delete ]; then
            echo "Could not finalize SQLite backup: $source" >&2
            exit 1
          fi
          if [ "$(${pkgs.sqlite}/bin/sqlite3 -readonly "$tmp" 'PRAGMA quick_check;')" != ok ]; then
            echo "SQLite integrity check failed: $source" >&2
            exit 1
          fi
          rm -f -- "/var/backup/sqlite/$name-wal" "/var/backup/sqlite/$name-shm"
          mv -f -- "$tmp" "/var/backup/sqlite/$name"
          tmp=""
        }

        backup_sqlite /var/lib/bitwarden_rs/db.sqlite3 vaultwarden.db
        backup_sqlite /var/lib/headscale/db.sqlite headscale.db
        backup_sqlite /var/lib/private/goatcounter/goatcounter-data/db.sqlite3 goatcounter.db
        backup_sqlite /var/lib/private/gotify-server/data/gotify.db gotify.db
        backup_sqlite /var/lib/grafana/data/grafana.db grafana.db
        backup_sqlite /var/lib/private/open-webui/data/webui.db open-webui.db
        backup_sqlite /var/lib/private/open-webui/data/vector_db/chroma.sqlite3 open-webui-chroma.db
        backup_sqlite /root/.local/share/opencode/opencode.db opencode.db
      '';

      timerConfig = {
        OnCalendar = "Mon,Thu *-*-* 03:00:00";
        Persistent = true;
        RandomizedDelaySec = "2h";
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
        "--keep-tag archive-moon"
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
    requires = [
      "postgresqlBackup-dawarich.service"
      "postgresqlBackup-sharry.service"
    ];
    after = [
      "postgresqlBackup-dawarich.service"
      "postgresqlBackup-sharry.service"
    ];
  };
}
