# No connection details, repository location or ntfy credentials appear here or
# in the host's configuration.nix, they live in out-of-store, uncommitted files
# under /etc/restic/:
#
# connect.sh  env  known_hosts  password  repository  ssh_key
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.myBackup;
  hostname = config.networking.hostName;

  # Single source of truth for what gets backed up, so the backup job and the
  # per-path freshness check can never drift apart.
  paths = [ cfg.homeDir ];

  # The NixOS restic module wires repo/password/sftp for the backup job itself.
  # The verify and freshness jobs are hand-rolled, so they spell it out: restic
  # reads RESTIC_*_FILE from the environment, and the sftp connection script is
  # passed as an -o option (a path, nothing secret, nothing for a shell to
  # expand).
  resticEnv = lib.mapAttrsToList (n: v: "${n}=${v}") {
    RESTIC_REPOSITORY_FILE = cfg.repositoryFile;
    RESTIC_PASSWORD_FILE = cfg.passwordFile;
  };
  restic = "${pkgs.restic}/bin/restic -o sftp.command=${cfg.sftpCommand}";

  # Build a oneshot service that pushes one ntfy message, used as an OnFailure=
  # target. An automated check that fails silently is theatre, so every job
  # below points at one of these.
  mkNotify = name: message: {
    "restic-notify-${name}" = {
      description = "Notify via ntfy that restic ${name} failed";
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = cfg.environmentFile;
        ExecStart = pkgs.writeShellScript "restic-notify-${name}" ''
          ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 \
            ''${NTFY_TOKEN:+-H "Authorization: Bearer $NTFY_TOKEN"} \
            -H "Title: restic ${name}" \
            -H "Priority: max" \
            -d ${lib.escapeShellArg message} \
            "$NTFY_TOPIC" || true
        '';
      };
    };
  };
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
            -o UserKnownHostsFile=/etc/restic/known_hosts \
            -o StrictHostKeyChecking=yes \
            -p 23 uXXXXX@uXXXXX.your-storagebox.de -s sftp
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

    verifyCalendar = lib.mkOption {
      type = lib.types.str;
      default = "Mon *-*-* 03:00:00";
      description = ''
        OnCalendar for the weekly read-data-subset verify. Set distinct times
        per host so two repos don't both saturate the Storage Box link.
      '';
    };

    freshnessCalendar = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = ''
        OnCalendar for the daily snapshot-freshness check. Daily because
        staleness is time-sensitive and the check is metadata-only (near-free).
      '';
    };

    freshnessThresholdDays = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = ''
        Fail the freshness check if a path's latest snapshot is older than
        this many days. Must comfortably exceed the backup interval plus margin
        or a single long/skipped run false-alarms (3 fits a daily backup).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups.fleet = {
      repositoryFile = cfg.repositoryFile;
      passwordFile = cfg.passwordFile;
      environmentFile = cfg.environmentFile;

      # restic's sftp backend invokes this script to connect. It is a path to
      # an out-of-store executable — no variable, nothing for a shell to
      # expand, so the connection details stay out of git and the store.
      extraOptions = [ "sftp.command=${cfg.sftpCommand}" ];

      paths = paths;

      exclude = [
        "${cfg.homeDir}/.cache"
        "${cfg.homeDir}/.julia/compiled"
        "${cfg.homeDir}/.spotify"
        "venv"
        ".venv"
      ];
      extraBackupArgs = [
        "--exclude-caches"
        "--verbose"
      ];

      initialize = false; # init once by hand — auto-init masks repo-path typos.
      runCheck = false; # verification is a separate job (separate timer/script).
      pruneOpts = [ ]; # no prune here — prune is a separate, less-frequent job.

      inhibitsSleep = true; # don't let a laptop suspend mid-backup.

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true; # catch up on next boot if the host was off.
        RandomizedDelaySec = "1h";
      };
    };

    systemd.services = lib.mkMerge [
      {
        # ── Verify: weekly read-data-subset ──────────────────────────────────
        # Rolling n/53 partition by pack ID: ~1/53 of packs per run, whole repo
        # covered over a year, deterministically and statelessly. Runs the full
        # structural check too, so no separate plain `check` is needed. check is
        # a non-exclusive lock, so it never collides with backup; schedule it
        # away from the backup so it can't overlap the (exclusive) prune in it.
        restic-verify-fleet = {
          description = "restic repository verification (check --read-data-subset)";
          onFailure = [ "restic-notify-verify.service" ];
          # connect.sh does `exec ssh …`; the NixOS restic module puts openssh
          # on the backup unit's path, so these hand-rolled jobs need it too.
          path = [ pkgs.openssh ];
          serviceConfig = {
            Type = "oneshot";
            Environment = resticEnv;
            ExecStart = pkgs.writeShellScript "restic-verify-fleet" ''
              set -euo pipefail
              # 10# forces base-10 so ISO weeks 08/09 don't parse as bad octal.
              WEEK=$((10#$(${pkgs.coreutils}/bin/date +%V)))
              exec ${restic} check --read-data-subset="''${WEEK}/53"
            '';
          };
        };

        # ── Freshness: daily per-path snapshot age ───────────────────────────
        # Outcome-based backstop: asserts a recent restorable snapshot exists,
        # rather than trusting the timer to have fired. Catches the failure mode
        # OnFailure can't — a backup that silently stopped firing entirely.
        # Checked per --path, not repo-wide: if one path's backup dies while
        # another keeps running, a repo-wide "latest ≤ N days" check stays green.
        restic-freshness-fleet = {
          description = "restic snapshot freshness check (per-path)";
          onFailure = [ "restic-notify-freshness.service" ];
          path = [ pkgs.openssh ];   # connect.sh needs ssh on PATH; see above.
          serviceConfig = {
            Type = "oneshot";
            Environment = resticEnv;
            # No `set -e`: report every path, not just the first stale one.
            ExecStart = pkgs.writeShellScript "restic-freshness-fleet" ''
              set -uo pipefail
              threshold=$((${toString cfg.freshnessThresholdDays} * 24 * 3600))
              now=$(${pkgs.coreutils}/bin/date +%s)
              fail=0
              for p in ${lib.escapeShellArgs paths}; do
                ts=$(${restic} snapshots --path "$p" --latest 1 --json \
                       | ${pkgs.jq}/bin/jq -r '.[0].time // empty')
                if [ -z "$ts" ] \
                   || (( now - $(${pkgs.coreutils}/bin/date -d "$ts" +%s) > threshold )); then
                  echo "stale or missing snapshot for path: $p" >&2
                  fail=1
                fi
              done
              exit $fail
            '';
          };
        };

        # ── Failure notification on the backup itself ────────────────────────
        # OnFailure fires on any non-zero restic exit, including 3 (read errors).
        "restic-backups-fleet".onFailure = [ "restic-notify-backup.service" ];
      }

      # An automated check that fails silently is theatre, so every job points
      # at one of these ntfy notifiers.
      (mkNotify "backup" "Backup FAILED on ${hostname} (journalctl -u restic-backups-fleet).")
      (mkNotify "verify" "Verify FAILED on ${hostname}: check --read-data-subset (journalctl -u restic-verify-fleet).")
      (mkNotify "freshness" "Freshness check FAILED on ${hostname}: a snapshot is stale or missing (journalctl -u restic-freshness-fleet).")
    ];

    systemd.timers = {
      restic-verify-fleet = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.verifyCalendar;
          Persistent = true; # catch up on next boot if the host was off.
          RandomizedDelaySec = "30m";
        };
      };

      restic-freshness-fleet = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.freshnessCalendar;
          Persistent = true;
          RandomizedDelaySec = "30m";
        };
      };
    };
  };
}
