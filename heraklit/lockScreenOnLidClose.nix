# lock screen on lid close should work like this
  systemd.user.services.lockScreenOnSuspend = {
    # before = [ "sleep.target" ];
    description = "Lock the screen on resume from suspend";
    serviceConfig = {
      User = "%I";
      Environment = "DISPLAY=:0";
      ExecStart = "/var/setuid-wrappers/slock";
      # Type = "simple";
    };
    wantedBy = [ "suspend.target" ];
    # wantedBy = [ "sleep.target" ];
  };

# or like this, but it doesn't
  services.acpid.enable = true;
  services.acpid.lidEventCommands = ''
    logger -t lid-handler "LID THINGS HAPPENING"
    LID="/proc/acpi/button/lid/LID0/state"
    state=`cat $LID | ${pkgs.gawk}/bin/awk '{print $2}'`
    case "$state" in
      *open*)
        logger -t lid-handler "LID OPENED"
        /var/setuid-wrappers/slock
        ;;
      *close*)
        logger -t lid-handler "LID CLOSED"
        /var/setuid-wrappers/slock
        ;;
      *) logger -t lid-handler "Failed to detect lid state ($state)" ;;
    esac
  '';
