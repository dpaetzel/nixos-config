{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "neo";

    # TODO only laptops needs this
    libinput = {
      enable = true;
      disableWhileTyping = true;
      scrollMethod = "twofinger";
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
    # desktopManager.default = "custom";
    # TODO this might need to be commented out (x did not start with it and {desktop,window}Manager.default)
    # NOTE I have to run slay w m each time anyway
    # desktopManager.session = [
    #   { name = "custom";
    #     start = ''
    #       ${pkgs.setroot}/bin/setroot --solid-color '#000000'
    #       ${pkgs.unclutter}/bin/unclutter -idle 5 -root &
    #       ${pkgs.xlibs.xset}/bin/xset -b
    #       # ${pkgs.autocutsel}/bin/autocutsel -pause 5000 -s PRIMARY -f
    #       # ${pkgs.autocutsel}/bin/autocutsel -pause 5000 -s SELECTION -f
    #       # ${pkgs.compton}/bin/compton --daemon
    #       # TODO put conkyrc into nixos config
    #       # ${pkgs.conky}/bin/conky --pause 5 --daemonize
    #       # TODO put dunstrc into nixos config
    #       # sleep 5 && ${pkgs.dunst}/bin/dunst &

    #       # sleep 7 && ${pkgs.emacs}/bin/emacsclient -c -a emacs &
    #       # sleep 7 && ${pkgs.firefox}/bin/firefox &
    #     '';
    #   }
    # ];

    # # TODO is this needed?
    # windowManager.default = "xmonad";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages : [ haskellPackages.split ];
    };

    # TODO put xresources etc directly into nixos config?
    # ${pkgs.xlibs.xrdb}/bin/xrdb -load ${./Xresources}
  };
}
