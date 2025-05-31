systemd.user.services.batterywarn = let
  batterywarnscript = pkgs.writeShellApplication {
    name = "batterywarner";
    runtimeInputs = [pkgs.zenity];
    text = ''
      # Set battery warning threshold
      threshold=15  # Change this to your preferred percentage

      while true; do
          battery_level=$(cat /sys/class/power_supply/BAT0/capacity)
          charging_status=$(cat /sys/class/power_supply/BAT0/status)

          if [[ "$battery_level" -lt "$threshold" && "$charging_status" != "Charging" ]]; then
              zenity --warning --title="Battery Low" --text="Battery at $battery_level%. Plug in now!" --timeout=10
          fi

          sleep 60  # Check every 60 seconds
      done
    '';
  };
    in {
  Unit = {
    Description = "Battery warnings";
  };
  Install = {
    WantedBy = [ "default.target" ];
  };
  Service = {
    # It is recommended to use Type=exec for long-running services, as it
    # ensures that process setup errors (e.g. errors such as a missing service
    # executable, or missing user) are properly tracked.
    Type = "exec";
    # WorkingDirectory = "/home/david/Zettels";
    ExecStart = "${batterywarnscript}";
    TimeoutStartSec = 30;
    Restart = "always";
  };
};
