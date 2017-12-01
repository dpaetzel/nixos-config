{ config, pkgs, ... }:

# TODO put all xmonad-startup stuff into services.xserver.desktopManager.session:
# see https://github.com/bennofs/etc-nixos/blob/master/conf/desktop.nix
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

{
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

  # “Turn on this option if you want to enable all the firmware shipped in
  # linux-firmware.”
  hardware.enableAllFirmware = true;

  # „On 64-bit systems, whether to support Direct Rendering for 32-bit
  # applications (such as Wine). This is currently only supported for the nvidia
  # and ati_unfree drivers, as well as Mesa.“
  hardware.opengl.driSupport32Bit = true;

  # Networking.
  networking = {
    networkmanager.enable = true;
    extraHosts = ''
      192.168.2.100 anaxagoras
      192.168.2.101 heraklit
      192.168.2.102 sokrates
      192.168.2.110 filius
    '';
    firewall.enable = false;
  };

  # Installed fonts.
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      cm_unicode
      corefonts
      dejavu_fonts
      fira
      fira-code
      fira-mono
      inconsolata
      # ipafont
      kochi-substitute
      libertine
      lmmath
      lmodern
      source-code-pro
      symbola
      terminus_font
      ubuntu_font_family
      unifont
      vistafonts
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;

    chromium.pulseSupport = true;
    # chromium = {
    #   enablePepperFlash = true;
    #   enablePepperPDF = true;
    # };
  };


  # TODO restructure GTK themes
  # see https://github.com/bennofs/etc-nixos/blob/master/conf/desktop.nix

  environment.extraInit = ''
    # QT: remove local user overrides (for determinism, causes hard to find bugs)
    rm -f ~/.config/Trolltech.conf

    # GTK3: remove local user overrides (for determinisim, causes hard to find bugs)
    rm -f ~/.config/gtk-3.0/settings.ini

    # GTK3: add breeze theme to search path for themes
    # (currently, we need to use gnome-breeze because the GTK3 version of kde5.breeze is broken)
    export XDG_DATA_DIRS="${pkgs.gnome-breeze}/share:$XDG_DATA_DIRS"

    # GTK3: add /etc/xdg/gtk-3.0 to search path for settings.ini
    # We use /etc/xdg/gtk-3.0/settings.ini to set the icon and theme name for GTK 3
    export XDG_CONFIG_DIRS="/etc/xdg:$XDG_CONFIG_DIRS"

    # GTK2 theme + icon theme
    export GTK2_RC_FILES=${pkgs.writeText "iconrc" ''gtk-icon-theme-name="breeze"''}:${pkgs.breeze-gtk}/share/themes/Breeze/gtk-2.0/gtkrc:$GTK2_RC_FILES

    # SVG loader for pixbuf (needed for GTK svg icon themes)
    export GDK_PIXBUF_MODULE_FILE=$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)

    # TODO here dircolors stuff

    # QT5: convince it to use our preferred style
    export QT_STYLE_OVERRIDE=breeze

    # these are the defaults, but some applications are buggy so we set them
    # here anyway
    export XDG_CONFIG_HOME=$HOME/.config
    export XDG_DATA_HOME=$HOME/.local/share
    export XDG_CACHE_HOME=$HOME/.cache
  '';

  # LS colors
  # TODO not working, don't know anyway, what it does
  # eval `${pkgs.coreutils}/bin/dircolors "${./dircolors}"`

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
    breeze-icons

    # Icons (Fallback)
    gnome3.adwaita-icon-theme
    hicolor_icon_theme

    # These packages are used in autostart, they need to in systemPackages
    # or icons won't work correctly
    pythonPackages.udiskie skype
  ];

  environment.pathsToLink = [ "/share" ];

  # end GTK themes


  environment.variables = {
    BROWSER = "chromium";

    # Prevent DBUS.Error.ServiceUnknown: org.a11y.Bus not provided.
    # https://github.com/NixOS/nixpkgs/issues/16327
    NO_AT_BRIDGE = "1";

    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";

    # Prevent Wine from changing filetype associations.
    # https://wiki.winehq.org/FAQ#How_can_I_prevent_Wine_from_changing_the_filetype_associations_on_my_system_or_adding_unwanted_menu_entries.2Fdesktop_links.3F
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";
  };

  # Proper backlight management.
  programs.light.enable = true;

  programs.zsh.enable = true;
  programs.fish.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    displayManager.slim = {
      defaultUser = "david";
      enable = true;
      theme = pkgs.fetchurl {
        url = "https://github.com/edwtjo/nixos-black-theme/archive/v1.0.tar.gz";
        sha256 = "13bm7k3p6k7yq47nba08bn48cfv536k4ipnwwp1q1l2ydlp85r9d";
      };
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages : [ haskellPackages.split ];
    };

    # otherwise an xterm spawns the window manager(?!?)
    desktopManager.xterm.enable = false;
  };

  services.redshift.enable = true;
  services.redshift.latitude = "48.3";
  services.redshift.longitude = "10.9";
  services.redshift.temperature.day = 5500;
  services.redshift.temperature.night = 2800;

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  # must be disabled for GnuPGAgent to work (or so someone said)
  programs.ssh.startAgent = false;

  i18n = {
    consoleFont = "lat9w-16";
  };
  time.timeZone = "Europe/Berlin";
}
