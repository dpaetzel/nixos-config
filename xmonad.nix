# TODO this

# Enable the X11 windowing system.
services.xserver = {
  enable = true;
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

  displayManager.job.logToJournal = true;
  displayManager.lightdm.enable = true;
  displayManager.lightdm.autoLogin = {
    enable = true;
    user = "david";
  };
  displayManager.lightdm.greeter.enable = false;
  # TODO autologin only if hard drive is encrypted
  desktopManager.session =
    [ { name = "custom";
        start = ''
          # TODO put xresources into nixos config
          ${pkgs.xlibs.xrdb}/bin/xrdb -load ${./Xresources}

          ${pkgs.autocutsel}/bin/autocutsel -s PRIMARY -f
          ${pkgs.autocutsel}/bin/autocutsel -s SELECTION -f
          ${pkgs.compton}/bin/compton
          ${pkgs.unclutter}/bin/unclutter -idle 5 -root
          ${pkgs.xlibs.xset}/bin/xset -b
          # TODO put conkyrc into nixos config
          sleep 2 && ${pkgs.conky}/bin/conky
          # TODO put dunstrc into nixos config
          sleep 5 && ${pkgs.dunst}/bin/dunst

          sleep 7 && ${pkgs.emacs}/bin/emacsclient -c -a emacs
          sleep 7 && ${pkgs.chromium}/bin/chromium
        '';
      }
    ];
    # [ { name = "custom";
    #     start = ''
    #       # Lock
    #       ${expr.lock}/bin/lock
    #       ${expr.lock-suspend}/bin/lock-on-suspend &

    #       ${pkgs.haskellPackages.xmobar}/bin/xmobar --dock --alpha 200 &
    #       ${pkgs.stalonetray}/bin/stalonetray --slot-size 22 --icon-size 20 --geometry 9x1-0 --icon-gravity NE --grow-gravity E -c /dev/null --kludges fix_window_pos,force_icons_size,use_icons_hints --transparent --tint-level 200 &> /dev/null &
    #       ${pkgs.xlibs.xrdb}/bin/xrdb -load ${./Xresources}

    #       # Autostart
    #       ${pkgs.lib.optionalString (!buildVM) ''
    #         ${pkgs.rxvt_unicode}/bin/urxvt -title "IRC bennofs" -e ${pkgs.weechat}/bin/weechat &
    #       ''}
    #       ${pkgs.rxvt_unicode}/bin/urxvtd &
    #       ${pkgs.pasystray}/bin/pasystray &> /dev/null &
    #       ${pkgs.unclutter}/bin/unclutter -idle 3 &
    #       ${pkgs.pythonPackages.udiskie}/bin/udiskie --tray &
    #       ${pkgs.wpa_supplicant_gui}/bin/wpa_gui -q -t &
    #       ${pkgs.dunst}/bin/dunst -cto 4 -nto 2 -lto 1 -config ${./dunstrc} &
    #       syndaemon -i 1 -R -K -t -d
    #       trap 'trap - SIGINT SIGTERM EXIT && kill 0 && wait' SIGINT SIGTERM EXIT
    #       ${pkgs.lib.optionalString buildVM '' ${pkgs.rxvt_unicode}/bin/urxvt '' }
    #     '';
    #   }
    # ];
  desktopManager.default = "custom";
  desktopManager.xterm.enable = false;

  # TODO is this needed?
  windowManager.default = "xmonad";
  windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    extraPackages = haskellPackages : [ haskellPackages.split ];
  };
};

