{ config, pkgs, expr, buildVM, ... }:

let
  iconTheme = pkgs.breeze-icons.out;
  themeEnv = ''
  '';

in {

imports = [];

# Required for our screen-lock-on-suspend functionality
# services.logind.extraConfig = ''
#   LidSwitchIgnoreInhibited=False
#   HandleLidSwitch=suspend
#   HoldoffTimeoutSec=10
# '';

# Enable the X11 windowing system.
services.xserver = {
  # enable = true;
  # layout = "de";
  # synaptics.enable = true;
  # synaptics.accelFactor = "0.01";
  # synaptics.twoFingerScroll = true;
  # synaptics.additionalOptions = ''
  #   Option "VertScrollDelta" "-112"
  #   Option "HorizScrollDelta" "-112"
  #   Option "TapButton2" "3"
  #   Option "TapButton3" "2"
  # '';
  # xkbOptions = "ctrl:nocaps";

  # displayManager.logToJournal = true;
  # displayManager.lightdm.enable = true;
  # displayManager.lightdm.autoLogin = {
  #   enable = true;
  #   user = "bennofs";
  # };
  # displayManager.lightdm.greeter.enable = false;
  # desktopManager.session =
  #   [ { name = "custom";
  #       start = ''
  #         # Lock
  #         ${expr.lock}/bin/lock
  #         ${expr.lock-suspend}/bin/lock-on-suspend &

  #         ${pkgs.haskellPackages.xmobar}/bin/xmobar --dock --alpha 200 &
  #         ${pkgs.stalonetray}/bin/stalonetray --slot-size 22 --icon-size 20 --geometry 9x1-0 --icon-gravity NE --grow-gravity E -c /dev/null --kludges fix_window_pos,force_icons_size,use_icons_hints --transparent --tint-level 200 &> /dev/null &
  #         ${pkgs.xlibs.xrdb}/bin/xrdb -load ${./Xresources}

  #         # Autostart
  #         ${pkgs.lib.optionalString (!buildVM) ''
  #           ${pkgs.rxvt_unicode}/bin/urxvt -title "IRC bennofs" -e ${pkgs.weechat}/bin/weechat &
  #         ''}
  #         ${pkgs.rxvt_unicode}/bin/urxvtd &
  #         ${pkgs.pasystray}/bin/pasystray &> /dev/null &
  #         ${pkgs.unclutter}/bin/unclutter -idle 3 &
  #         ${pkgs.pythonPackages.udiskie}/bin/udiskie --tray &
  #         ${pkgs.wpa_supplicant_gui}/bin/wpa_gui -q -t &
  #         ${pkgs.dunst}/bin/dunst -cto 4 -nto 2 -lto 1 -config ${./dunstrc} &
  #         syndaemon -i 1 -R -K -t -d
  #         trap 'trap - SIGINT SIGTERM EXIT && kill 0 && wait' SIGINT SIGTERM EXIT
  #         ${pkgs.lib.optionalString buildVM '' ${pkgs.rxvt_unicode}/bin/urxvt '' }
  #       '';
  #     }
  #   ];
  # desktopManager.default = "custom";
  # desktopManager.xterm.enable = false;

  # windowManager.default = "xmonad";
  # windowManager.xmonad.enable = true;
  # windowManager.xmonad.enableContribAndExtras = true;
};

environment.extraInit = ''
  ${themeEnv}

  # these are the defaults, but some applications are buggy so we set them
  # here anyway
  export XDG_CONFIG_HOME=$HOME/.config
  export XDG_DATA_HOME=$HOME/.local/share
  export XDG_CACHE_HOME=$HOME/.cache
'';

# QT4/5 global theme
environment.etc."xdg/Trolltech.conf" = {
  text = ''
    [Qt]
    style=Breeze
  '';
  mode = "444";
};

# GTK3 global theme (widget and icon theme)
environment.etc."xdg/gtk-3.0/settings.ini" = {
  text = ''
    [Settings]
    gtk-icon-theme-name=breeze
    gtk-theme-name=Breeze-gtk
  '';
  mode = "444";
};

environment.systemPackages = with pkgs; [
  # Qt theme
  breeze-qt5
  breeze-qt4

  # Icons (Main)
  iconTheme

  # Icons (Fallback)
  gnome3.adwaita-icon-theme
  hicolor_icon_theme

  # These packages are used in autostart, they need to in systemPackages
  # or icons won't work correctly
  pythonPackages.udiskie skype
];

# Make applications find files in <prefix>/share
environment.pathsToLink = [ "/share" ];

}
