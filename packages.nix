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
      abcde # for occasionally ripping CDs
      adobe-reader # for occasionally having to read comments in PDFs
      androidsdk # for getting files from android phones
      anki
      audacity lame
      chromium
      docker
      dropbox-cli
      emacs
      geeqie
      gimp
      gnupg
      google-chrome # for DRM-protected streaming
      gparted
      libreoffice
      lilyterm
      mediathekview
      mpv # much faster than big ol' vlc
      # musescore # TODO is marked broken?
      simplescreenrecorder
      tdesktop
      teamviewer # sometimes needed, happy when its already installed
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
      trayer
      udiskie
      xorg.xev
      xdotool
    ];
  };

  # useful esp. if there is no desktop environment
  graphical-user-interface = [
    autocutsel # the only sane(?) clipboard management
    conky
    compton
    dmenu2
    dunst
    dzen2
    libnotify
    lxappearance
    networkmanagerapplet
    # parcellite
    setroot
    xfce.thunar
    unclutter

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
    # python3Packages.urlscan # not yet there?
  ];

  commandline = {
    main = [
      atool
      curl
      dfc
      git
      # gitAndTools.git-annex # its broken, so I installed it from master…
      ledger
      lzip # some people do use LZMA compression
      mr
      rcm
      p7zip
      pandoc
      pass
      tree
      unzip
      weechat
      zip
    ];
    utility = [
      cifs-utils
      dosfstools
      entr
      file
      ghostscript
      htop
      imagemagick
      ffmpeg
      lsof
      manpages
      nix-prefetch-git
      nix-repl
      nix-zsh-completions
      (nmap.override { graphicalSupport = true; })
      pastebinit
      pdfgrep
      pmount
      psmisc
      pv
      python27Packages.goobook
      quvi # flash video scraper/getter/…
      silver-searcher
      telnet
      tmux
      traceroute
      wget
      wirelesstools
      which
      whois
      youtube-dl
      xclip
    ];
  };

  development = [
    automake autoconf # always annoying when these are needed but not available
    cabal-install
    cloc
    elmPackages.elm
    gcc
    gdb # sometimes you need it
    ghc
    gnumake
    haskellPackages.ghc-mod
    haskellPackages.hlint
    haskellPackages.lhs2tex
    patchelf # so handy
    python
    ruby
    sbt
    scala
    stack
  ];
}
