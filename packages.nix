pkgs :


let
  nixpkgs20191003 = import (builtins.fetchGit {
    name = "nixpkgs-2019-10-03";
    url = https://github.com/nixos/nixpkgs/;
    rev = "406335aeb139ca5510c724c730e4f5ea83ad8cf3";
  }) {};
in


with pkgs; {
  system = [
    cryptsetup
    ntfs3g
  ];
  applications = {
    main = [
      abcde # for occasionally ripping CDs
      adobe-reader # for occasionally having to read comments in PDFs
      androidenv.androidPkgs_9_0.androidsdk
      audacity lame
      chromium
      diffpdf
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
      libreoffice
      lilyterm
      # mediathekview # TODO broken
      mpv # much faster than big ol' vlc
      musescore
      # openshot-qt # if I should ever want to edit video
      signal-desktop
      simplescreenrecorder
      skype # too many people use this -.-
      spotify
      tabula # for extracting tables from PDFs
      tdesktop
      teamviewer # sometimes needed, happy when its already installed
      thunderbird
      tor-browser-bundle-bin
      vimHugeX # huge b/c want to have gvim around
      vlc # wow, much simple to use, much support
      # NOTE broken due to "error: undefined reference to '__divmoddi4'"
      # wine winetricks # always handy to keep around; you never know x)
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
    dmenu
    dunst
    dzen2
    libnotify
    lxappearance
    networkmanagerapplet
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
      ffmpeg
      fzf # fuzzy file finder
      git
      # khal # TODO broken, install from master
      khard
      gitAndTools.git-annex
      nixpkgs20191003.hugo
      nixpkgs20191003.khal # calendar
      ledger
      lzip # some people do use LZMA compression
      magic-wormhole
      mr
      nix-index # builds an index for `nix-locate` which helps me to search my nix-store
      rcm
      p7zip
      pandoc
      (pass.withExtensions (ext: with ext; [ pass-otp pass-update ]))
      transmission
      tree
      unrar
      unzip
      # vdirsyncer # for fetching my calendars # TODO broken, install from master
      weechat
      zip
    ];
    utility = [
      acpi # needed for more nicely formatted battery status in conky
      bind # needed for the occasional `dig`
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
    # cabal2nix # TODO currently broken, install from master
    cabal-install
    cloc
    # elmPackages.elm # TODO currently not working
    gcc
    gdb # sometimes you just need it
    gnumake
    # haskellPackages.ghcWithPackages (pkgs: [pkgs.turtle]) # TODO this is currently not working (can't coerce function to string, even with empty list)
    haskellPackages.ghc
    # haskellPackages.ghc-mod # TODO currently not working
    haskellPackages.hlint
    # haskellPackages.lhs2tex # TODO not working
    # nodejs
    openjdk
    patchelf # so handy
    python
    python37Packages.yapf
    R
    ruby
    sbt
    scala
    shellcheck
    stack
    weka
  ];
}
