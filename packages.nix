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
      dropbox-cli
      emacs
      geeqie
      gimp
      gnupg
      gparted
      libreoffice
      lilyterm
      mediathekview
      redshift
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
    elinks
    gnupg
    msmtp
    neomutt
    notmuch
    offlineimap
  ];

  commandline = {
    main = [
      atool
      curl
      dfc
      git
      gitAndTools.git-annex
      ledger
      rcm
      p7zip
      pass
      # pdfjam
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
      nix-prefetch-git
      nix-repl
      (nmap.override { graphicalSupport = true; })
      pmount
      psmisc
      python35Packages.rainbowstream
      python27Packages.goobook
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
    cabal-install
    cloc
    gcc
    ghc
    gnumake
    haskellPackages.hlint
    ruby
    sbt
    scala
    stack
  ];
}
