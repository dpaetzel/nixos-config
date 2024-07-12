{ writeShellScriptBin, setxkbmap, xdotool }:

# Workaround which I used before figuring out to switch keyboad layouts before
# `xdotool type`.
# printf "¯\_(ツ)_/¯" | xclip
(writeShellScriptBin "shrug" ''
  ${setxkbmap}/bin/setxkbmap -layout us
  ${xdotool}/bin/xdotool type "¯\_(ツ)_/¯"
  ${setxkbmap}/bin/setxkbmap -layout de -variant neo
'')
