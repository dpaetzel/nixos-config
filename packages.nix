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
      audacity lame
      chromium
      cutegram
      dropbox-cli
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
      wine winetricks # always handy to keep around; you never know x)
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

    # works
    gnome3.adwaita-icon-theme
    arc-icon-theme
    paper-icon-theme

    # works probably
    gtk-engine-murrine

    # all(?) themes, probably not working at all
    # `command ag --nonumbers misc.themes ~/Code/nixpkgs/pkgs/top-level/all-packages.nix`
    # adapta-gtk-theme
    # albatross
    # arc-theme
    # blackbird
    # clearlooks-phenix
    # flat-plat
    # gnome-breeze
    # greybird
    # gtk-engine-murrine
    # gtk_engines
    # numix-gtk-theme
    # orion
    # oxygen-gtk2
    # oxygen-gtk3
    # paper-gtk-theme
    # theme-vertex
    # zuki-themes
  ];

  mutt = [
    alot
    python35Packages.afew
    elinks
    gnupg
    msmtp
    # mutt-kz
    neomutt
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
