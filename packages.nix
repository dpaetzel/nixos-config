pkgs :

with pkgs; {
  system = [
    cryptsetup
    ntfs3g
  ];
  applications = {
    main = [
      abcde # for occasionally ripping CDs
      adobe-reader # for occasionally having to read comments in PDFs
      # androidenv.androidPkgs_9_0.android-tools # for getting files from android phones # TODO not working (2019-01-09)
      # anki # TODO currently broken?
      audacity lame
      chromium
      docker docker_compose
      dropbox-cli
      emacs
      evince
      firefox
      geeqie
      gimp
      gnupg
      gnuplot
      google-chrome # for DRM-protected streaming
      gparted
      inkscape
      # libreoffice # TODO currently broken?
      lilyterm
      mediathekview
      mpv # much faster than big ol' vlc
      musescore
      # openshot-qt # if I should ever want to edit video
      simplescreenrecorder
      skype # too many people use this -.-
      # spotify # TODO currently broken?
      tabula # for extracting tables from PDFs
      tdesktop
      teamviewer # sometimes needed, happy when its already installed
      thunderbird
      tor-browser-bundle-bin
      vimHugeX # huge b/c want to have gvim around
      virtualbox
      vlc # wow, much simple to use, much support
      wine winetricks # always handy to keep around; you never know x)
      (zathura.override { synctexSupport = false; }) # synctex makes the build fail
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
    # gnome3.adwaita-icon-theme
    # arc-icon-theme
    # paper-icon-theme

    # works probably
    # gtk-engine-murrine

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
    urlscan
  ];

  commandline = {
    main = [
      atool
      bup # backup solution
      curl
      dfc
      droopy # browser-based file sharing
      exa # a better `ls`
      fd # fast and user-friendly alternative to `find`
      fzf # fuzzy file finder
      git
      khal
      # khard # TODO not building
      # gitAndTools.git-annex # its broken, so I installed it from master…
      ledger
      lzip # some people do use LZMA compression
      mr
      nix-index # builds an index for `nix-locate` which helps me to search my nix-store
      rcm
      p7zip
      pandoc
      pass
      tree
      unrar
      unzip
      # vdirsyncer python36Packages.requests_oauthlib # its broken, so I installed it in nix-env
      weechat
      zip
    ];
    utility = [
      acpi # needed for more nicely formatted battery status in conky
      cifs-utils
      coreutils
      dosfstools
      entr
      file
      ghostscript
      htop
      imagemagick
      ffmpeg
      lm_sensors
      lsof
      manpages
      nix-prefetch-git
      nix-zsh-completions
      (nmap.override { graphicalSupport = true; })
      pastebinit
      pdfgrep
      pmount
      poppler_utils
      powertop
      psmisc
      pv
      # pythonPackages.goobook # TODO currently not working (but I don't need it anymore anyway)
      python36Packages.pygments
      quvi # flash video scraper/getter/…
      silver-searcher
      telnet
      tmux
      traceroute
      usbutils
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
    cabal2nix
    cabal-install
    cloc
    # TODO currently not working
    # elmPackages.elm
    gcc
    gdb # sometimes you just need it
    gnumake
    # TODO this is currently not working (can't coerce function to string, even with empty list)
    # haskellPackages.ghcWithPackages (pkgs: [pkgs.turtle])
    haskellPackages.ghc
    # TODO currently not working
    # haskellPackages.ghc-mod
    haskellPackages.hlint
    # TODO not working
    # haskellPackages.lhs2tex
    # nodejs
    patchelf # so handy
    python
    R
    ruby
    # rust cargo # to be able to run `mates`
    sbt
    scala
    shellcheck
    stack
    weka
  ];
}
