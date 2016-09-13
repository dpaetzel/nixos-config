pkgs :

with pkgs; {
  system = [
    # cacert
    # kbd
    # networkmanager_openconnect
  ];
  applications = {
    main = [
      androidsdk # for getting files from android phones
      anki
      chromium
      emacs
      gimp
      gnupg
      libreoffice
      lilyterm
      thunderbird
      vim
      vlc
      zathura
    ];
    # useful esp. if there is no desktop environment
    utility = [
      arandr
      feh
      pavucontrol
      scrot
      slock
      trayer
      xorg.xev
      xdotool
    ];
  };

  # useful esp. if there is no desktop environment
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

  commandline = {
    main = [
      atool
      dfc
      git
      gitAndTools.git-annex
      rcm
      unzip
      weechat
      zip
    ];
    utility = [
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
  };

  development = [
    gcc
    ghc
    gnumake
    ruby
    sbt
    scala
  ];
}
