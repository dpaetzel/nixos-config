{ writeShellApplication, dbus, gnugrep, gnused, coreutils, gawk }:

writeShellApplication {
  name = "info-spotify";

  runtimeInputs = [ dbus gnugrep gnused coreutils gawk ];

  text = builtins.readFile ./info-spotify;
}
