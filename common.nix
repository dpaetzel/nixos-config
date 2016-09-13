{ config, pkgs, ... }:

{
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

  # „On 64-bit systems, whether to support Direct Rendering for 32-bit
  # applications (such as Wine). This is currently only supported for the nvidia
  # and ati_unfree drivers, as well as Mesa.“
  hardware.opengl.driSupport32Bit = true;

  # Networking.
  networking = {
    networkmanager.enable = true;
    networkmanager.basePackages =
      with pkgs; {
        # needed for university vpn
        networkmanager_openconnect =
          pkgs.networkmanager_openconnect.override { openconnect = pkgs.openconnect_gnutls; };
        inherit networkmanager modemmanager wpa_supplicant
                networkmanager_openvpn networkmanager_vpnc
                networkmanager_pptp networkmanager_l2tp;
    };
    extraHosts = ''
      192.168.2.100 anaxagoras
      192.168.2.101 heraklit
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
      inconsolata
      # ipafont
      kochi-substitute
      source-code-pro
      symbola
      terminus_font
      ubuntu_font_family
      unifont
      vistafonts
    ];
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  main-applications = [
    androidsdk # for getting files from android phones
    anki
    chromium
    # cutegram
    emacs
    # firefox
    gimp
    gnupg
    libreoffice
    lilyterm
    thunderbird
    vim
    vlc
    zathura
  ];

  # if there is no desktop environment, these might be useful
  utility-applications = [
    arandr
    feh
    pavucontrol
    scrot
    slock
    trayer
    xorg.xev
    xdotool
  ];

  # if there is no desktop environment, these make up a nice UI
  graphical-user-interface = [
    conky
    dmenu2
    dunst
    dzen2
    libnotify
    lxappearance
    networkmanagerapplet
    parcellite
    redshift
    unclutter
    xcompmgr
  ];

  themes = [
    # numix-gtk-theme
    # numix-icon-theme
    # elementary-icon-theme
    # gtk-engine-murrine
    # arc-gtk-theme
  ];


  mutt = [
    elinks
    gnupg
    msmtp
    mutt
    offlineimap
    urlview
  ];

  main-cli-programs = [
    dfc
    git
    gitAndTools.git-annex
    rcm
    weechat
  ];

  utility-cli-programs = [
    dosfstools
    file
    htop
    manpages
    pmount
    psmisc
    (nmap.override { graphicalSupport = true; })
    silver-searcher
    telnet
    tmux
    traceroute
    wget curl
    which
  ];

  archive-managment = [
    atool
    unzip
    zip
  ];

  misc = [
    cacert
    kbd
    networkmanager_openconnect
  ];

  development = [
    gcc
    ghc
    gnumake
    ruby
    sbt
    scala
  ];

  nixpkgs.config = {
    allowUnfree = true;

    # this is a bad browser since pentadactyl's death
    # firefox = {
    #   enableGoogleTalkPlugin = true;
    #   enableAdobeFlash = true;
    # };

    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };
  };

  # proper backlight management
  programs.light.enable = true;

  programs.zsh.enable = true;
  programs.fish.enable = true;

  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
  };

  # must be disabled for GnuPGAgent to work
  programs.ssh.startAgent = false;

  i18n = {
    consoleFont = "lat9w-16";
    defaultLocale = "en_US.UTF-8";
  };
  time.timeZone = "Europe/Berlin";
}
