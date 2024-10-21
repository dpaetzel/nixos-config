{
  colors = {
    background = "#000000";
    background-alt = "#000000";
    foreground = "#C5C8C6";
    primary = "#F0C674";
    secondary = "#8ABEB7";
    alert = "#A54242";
    disabled = "#707880";
  };

  "bar/top" = {
    width = "100%";
    height = "24pt";
    radius = 6;

    background = "\${colors.background}";
    foreground = "\${colors.foreground}";

    line-size = "3pt";

    border-size = "0pt";
    border-color = "#00000000";

    padding-left = 0;
    padding-right = 1;

    module-margin = 1;

    separator = "|";
    separator-foreground = "\${colors.disabled}";

    font-0 = "monospace;2";

    modules-left = "pomodoro";
    modules-right = "xwindow xworkspaces";

    cursor-click = "pointer";
    cursor-scroll = "ns-resize";

    # https://polybar.readthedocs.io/en/stable/user/ipc.html
    enable-ipc = true;

    enable-struts = true;
  };

  "bar/bottom" = {
    bottom = true;

    width = "100%";
    height = "24pt";
    radius = 6;

    background = "\${colors.background}";
    foreground = "\${colors.foreground}";

    line-size = "3pt";

    border-size = "0pt";
    border-color = "#00000000";

    padding-left = 0;
    padding-right = 1;

    module-margin = 1;

    separator = "|";
    separator-foreground = "\${colors.disabled}";

    font-0 = "monospace;2";

    modules-left = "spotify";
    modules-right = "wlan eth filesystem xkeyboard memory cpu date";

    cursor-click = "pointer";
    cursor-scroll = "ns-resize";

    # https://polybar.readthedocs.io/en/stable/user/ipc.html
    enable-ipc = true;

    enable-struts = true;
  };

  "module/xworkspaces" = {
    type = "internal/xworkspaces";

    label-active = "%name%";
    label-active-background = "\${colors.background-alt}";
    label-active-underline = "\${colors.primary}";
    label-active-padding = 1;

    label-occupied = "%name%";
    label-occupied-padding = 1;

    label-urgent = "%name%";
    label-urgent-background = "\${colors.alert}";
    label-urgent-padding = 1;

    # I don't want to see empy workspaces in the bar.
    label-empty = "";
    # label-empty-foreground = "\${colors.disabled}";
    # label-empty-padding = 1;
  };

  "module/xwindow" = {
    type = "internal/xwindow";
    label = "%title:0:60:...%";
  };

  "module/filesystem" = {
    type = "internal/fs";
    interval = 25;

    mount-0 = "/";
    mount-1 = "/home";

    label-mounted = "%mountpoint%%{F-} %percentage_used%%";
    label-mounted-foreground = "\${colors.primary}";

    label-unmounted = "%mountpoint% not mounted";
    label-unmounted-foreground = "\${colors.disabled}";
  };

  "module/pulseaudio" = {
    type = "internal/pulseaudio";

    format-volume-prefix = "VOL ";
    format-volume-prefix-foreground = "\${colors.primary}";
    format-volume = "<label-volume>";

    label-volume = "%percentage%%";

    label-muted = "muted";
    label-muted-foreground = "\${colors.disabled}";
  };

  "module/xkeyboard" = {
    type = "internal/xkeyboard";
    blacklist-0 = "num lock";

    label-layout = "%layout%";
    label-layout-foreground = "\${colors.primary}";

    label-indicator-padding = 2;
    label-indicator-margin = 1;
    label-indicator-foreground = "\${colors.background}";
    label-indicator-background = "\${colors.secondary}";
  };

  "module/memory" = {
    type = "internal/memory";
    interval = 2;
    # format-prefix = "💾 ";
    format-prefix = "RAM ";
    format-prefix-foreground = "\${colors.primary}";
    label = "%percentage_used:2%%";
  };

  "module/cpu" = {
    type = "internal/cpu";
    interval = 2;
    # format-prefix = "🤖 ";
    format-prefix = "CPU ";
    format-prefix-foreground = "\${colors.primary}";
    label = "%percentage:2%%";
  };

  network-base = {
    type = "internal/network";
    interval = 5;
    format-connected = "<label-connected>";
    format-disconnected = "<label-disconnected>";
    label-disconnected = "%ifname%%{F#707880} disconnected";
    label-connected-foreground = "\${colors.primary}";
  };

  "module/wlan" = {
    "inherit" = "network-base";
    interface-type = "wireless";
    label-connected = "%ifname%%{F-} %essid% %local_ip%";
    label-connected-foreground = "\${colors.primary}";
  };

  "module/eth" = {
    "inherit" = "network-base";
    interface-type = "wired";
    label-connected = "%ifname%%{F-} %local_ip%";
    label-connected-foreground = "\${colors.primary}";
  };

  "module/date" = {
    type = "internal/date";
    interval = 1;

    date = "%Y-%m-%d %H:%M";
    date-alt = "%Y-%m-%d %H:%M:%S";

    label = "%date%";
    # label-foreground = "\${colors.foreground}";
  };

  settings = {
    screenchange-reload = true;
    pseudo-transparency = true;
  };

  "module/spotify" = {
    type = "custom/script";
    # We have to supply `0` right now because of the script being buggy, ignore
    # that.
    exec = "/run/current-system/sw/bin/info-spotify";
    interval = 5;
    label = "%output%";
  };

  "module/pomodoro" = {
    type = "custom/script";
    # We have to supply `0` right now because of the script being buggy, ignore
    # that.
    exec = "/run/current-system/sw/bin/pomodoro polybar 0";
    interval = 5;
    label = "🍅 %output%";
  };
}

# TODO Consider to add xmonad-log
# TODO Add volume
# "module/volume" = {
#   type = "internal/pulseaudio";
#   format.volume = " ";
#   label.muted.text = "🔇";
#   label.muted.foreground = "#666";
#   ramp.volume = ["🔈" "🔉" "🔊"];
#   click.right = "pavucontrol &";
# };
