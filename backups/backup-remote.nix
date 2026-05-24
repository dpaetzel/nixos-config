# No connection details, repository location or ntfy credentials appear here or
# in the host's configuration.nix, they live in out-of-store, uncommitted files
# under /etc/restic/.
{ config, lib, pkgs, ... }:

let
  cfg = config.services.myBackup;
  hostname = config.networking.hostName;
in
{
  options.services.myBackup = {
    enable = lib.mkEnableOption "restic backup to the Hetzner Storage Box";

    homeDir = lib.mkOption {
      type = lib.types.str;
      description = "Directory to back up.";
    };

    passwordFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/restic/password";
      description = "restic repository password. Out-of-store, uncommitted, chmod 600 root.";
    };

    repositoryFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/restic/repository";
      description = ''
        File whose sole contents are the restic repository string:
          sftp:uXXXXXX@uXXXXXX.your-storagebox.de:Backups/<hostname>
        Out-of-store, uncommitted, chmod 600 root.
      '';
    };

    sftpCommand = lib.mkOption {
      type = lib.types.str;
      default = "/etc/restic/connect.sh";
      description = ''
        Executable restic runs to open the sftp connection. Out-of-store and
        uncommitted, so the user/host/key never reach git. chmod 700 root.
        Contents, e.g.:

          #!/bin/sh
          exec ssh -F none -i /etc/restic/ssh_key -o IdentitiesOnly=yes \
            -p 23 uXXXXXX@uXXXXXX.your-storagebox.de -s sftp
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/restic/env";
      description = ''
        systemd EnvironmentFile, read at service start. Out-of-store,
        uncommitted, chmod 600 root. KEY=value lines, no surrounding quotes:

          NTFY_TOPIC=https://ntfy.sh/your-secret-topic
          NTFY_TOKEN=tk_xxxxxxxxxxxxxxxxxxxxx          # optional

        NTFY_TOPIC is mandatory. NTFY_TOKEN is optional; if absent, the
        request is sent without an Authorization header.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups.fleet = {
      repositoryFile  = cfg.repositoryFile;
      passwordFile    = cfg.passwordFile;
      environmentFile = cfg.environmentFile;

      # restic's sftp backend invokes this script to connect. It is a path to
      # an out-of-store executable — no variable, nothing for a shell to
      # expand, so the connection details stay out of git and the store.
      extraOptions = [ "sftp.command=${cfg.sftpCommand}" ];

      paths = [ cfg.homeDir ];

      exclude = [
        "${cfg.homeDir}/.cache"
        "${cfg.homeDir}/.julia/compiled"
        "${cfg.homeDir}/.spotify"
        "venv"
        ".venv"
      ];
      extraBackupArgs = [ "--exclude-caches" "--verbose" ];

      initialize = false;   # init once by hand — auto-init masks repo-path typos.
      runCheck   = false;   # verification is a separate job (separate timer/script).
      pruneOpts  = [ ];     # no prune here — prune is a separate, less-frequent job.

      inhibitsSleep = true; # don't let a laptop suspend mid-backup.

      timerConfig = {
        OnCalendar         = "daily";
        Persistent         = true;   # catch up on next boot if the host was off.
        RandomizedDelaySec = "1h";
      };
    };

    # ── Failure notification ───────────────────────────────────────────────
    # OnFailure fires on any non-zero restic exit, including 3 (read errors).
    systemd.services."restic-backups-fleet".onFailure =
      [ "restic-notify-fail.service" ];

    systemd.services.restic-notify-fail = {
      description = "Notify via ntfy that the restic backup failed";
      serviceConfig = {
        Type            = "oneshot";
        EnvironmentFile = cfg.environmentFile;
        ExecStart = pkgs.writeShellScript "restic-notify-fail" ''
          ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 \
            ''${NTFY_TOKEN:+-H "Authorization: Bearer $NTFY_TOKEN"} \
            -H "Title: restic backup" \
            -H "Priority: max" \
            -d "Backup FAILED on ${hostname} (journalctl -u restic-backups-fleet)." \
            "$NTFY_TOPIC" || true
        '';
      };
    };
  };
}
