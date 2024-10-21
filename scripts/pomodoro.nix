{ writeShellApplication, stdenv }:

# Workaround which I used before figuring out to switch keyboad layouts before
# `xdotool type`.
# printf "¯\_(ツ)_/¯" | xclip
writeShellApplication {
  name = "pomodoro";

  runtimeInputs = [ stdenv ];

  text = builtins.readFile ./pomodoro;
}
