{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "neo";

    # TODO hardware-dependent
    videoDrivers = [ "intel" ];

    # TODO only laptops needs this
    synaptics = {
      enable = true;
      minSpeed = "0.6";
      maxSpeed = "1.5";
      accelFactor = "0.015";
      twoFingerScroll = true;
      vertEdgeScroll = false;
      palmDetect = true;
    };

    # TODO autologin if hard drive is encrypted (thus device-dependent)
    displayManager.slim = {
      enable = true;
      defaultUser = "david";
      theme = pkgs.fetchurl {
        url = "https://github.com/edwtjo/nixos-black-theme/archive/v1.0.tar.gz";
        sha256 = "13bm7k3p6k7yq47nba08bn48cfv536k4ipnwwp1q1l2ydlp85r9d";
      };
    };

    desktopManager.xterm.enable = false;
    desktopManager.default = "custom";
    desktopManager.session = [
      { name = "custom";
        start = ''
          ${pkgs.setroot}/bin/setroot --solid-color '#000000'
          ${pkgs.autocutsel}/bin/autocutsel -s PRIMARY -f
          ${pkgs.autocutsel}/bin/autocutsel -s SELECTION -f
          ${pkgs.compton}/bin/compton --daemon
          ${pkgs.unclutter}/bin/unclutter -idle 5 -root &
          ${pkgs.xlibs.xset}/bin/xset -b
          # TODO put conkyrc into nixos config
          ${pkgs.conky}/bin/conky --pause 5 --daemonize
          # TODO put dunstrc into nixos config
          sleep 5 && ${pkgs.dunst}/bin/dunst &

          sleep 7 && ${pkgs.emacs}/bin/emacsclient -c -a emacs &
          sleep 7 && ${pkgs.chromium}/bin/chromium &
        '';
      }
    ];

    # TODO is this needed?
    windowManager.default = "xmonad";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages : [ haskellPackages.split ];
    };

    # TODO put xresources etc directly into nixos config
    # ${pkgs.xlibs.xrdb}/bin/xrdb -load ${./Xresources}
    #       ${pkgs.haskellPackages.xmobar}/bin/xmobar --dock --alpha 200 &
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
  };
}
