pkgs :

with pkgs; {
  system = [
    # needed e.g. for accessing gmail from offlineimap (enable using
    # security.pki.certificateFiles = ["${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"])
    cacert
    cryptsetup
    # kbd
    # networkmanager_openconnect
    ntfs3g
  ];
  applications = {
    main = [
      androidsdk # for getting files from android phones
      anki
      chromium
      cutegram
      emacs
      geeqie
      gimp
      gnucash
      gnupg
      gparted
      libreoffice
      lilyterm
      mediathekview
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
    xfce.thunar
    unclutter
    xcompmgr

    # numix-gtk-theme
    # numix-icon-theme
    # elementary-icon-theme
    # gtk-engine-murrine
    # arc-gtk-theme
  ];

  mutt = [
    alot
    python35Packages.afew
    elinks
    gnupg
    msmtp
    mutt-kz
    notmuch
    offlineimap
    urlview
  ];

  commandline = {
    main = [
      p7zip
      atool
      curl
      dfc
      git
      gitAndTools.git-annex
      ledger
      # haskellPackages.hledger
      # haskellPackages.hledger-web
      rcm
      pdfjam
      telegram-cli
      tree
      unzip
      weechat
      zip
    ];
    utility = [
      dosfstools
      file
      htop
      imagemagick
      lsof
      manpages
      nix-repl
      pmount
      psmisc
      (nmap.override { graphicalSupport = true; })
      silver-searcher
      telnet
      tmux
      traceroute
      wget
      wirelesstools
      which
      youtube-dl
    ];
  };

  development = [
    cloc
    gcc
    ghc
    gnumake
    ruby
    sbt
    scala
  ];
}
