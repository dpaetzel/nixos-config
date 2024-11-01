{ writeShellApplication, dbus, gnugrep, gnused, coreutils, gawk }:

writeShellApplication {
  name = "info-spotify";

  runtimeInputs = [ dbus gnugrep gnused coreutils gawk ];

  text = builtins.readFile ./info-spotify;

  # Don't set pipefail, the script is a bit ugly.
  bashOptions = ["errexit" "nounset"];
}
