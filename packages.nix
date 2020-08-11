pkgs :


let
  nixpkgs20191003 = import (builtins.fetchGit {
    name = "nixpkgs-2019-10-03";
    url = https://github.com/NixOS/nixpkgs/;
    rev = "406335aeb139ca5510c724c730e4f5ea83ad8cf3";
  }) {};
  # nixpkgs = import (builtins.fetchGit {
  #   # dunst doesn't seem to work
  #   name = "nixpkgs-2020-06-14";
  #   url = https://github.com/NixOS/nixpkgs/;
  #   rev = "c6c5c927ec48ec4c3fedaafc50bb9234abbe2039";
  # }) {
  nixpkgs20200702 = import (builtins.fetchGit {
    name = "nixpkgs-2020-07-02";
    url = https://github.com/NixOS/nixpkgs/;
    rev = "57568628beff33868e38ef7d17387a5a70075960";
  }) {
    config = {
      # The variable super refers to the Nixpkgs set before the overrides are
      # applied and self refers to it after the overrides are applied.
      # (https://stackoverflow.com/a/36011540/6936216)
      packageOverrides = super:
        let self = super.pkgs;
        in {
          # TODO 2020-05-12 p7zip is marked as insecure but I'm not sure whether
          # winetricks really always needs it?
          winetricks = super.winetricks.override (oldAttrs : rec {
            p7zip = "";
          });
        };
    };
  };
  nixpkgs = import (builtins.fetchGit {
    name = "nixpkgs-2020-08-11";
    url = https://github.com/NixOS/nixpkgs/;
    rev = "f9eba87bf03318587df8356a933f20cfbc81c6ee";
  }) {
  # TODO Pin winetricks and wine!
    config = {
      android_sdk.accept_license = true;
      oraclejdk.accept_license = true;
      allowUnfree = true;

      chromium.pulseSupport = true;

      # The variable super refers to the Nixpkgs set before the overrides are
      # applied and self refers to it after the overrides are applied.
      # (https://stackoverflow.com/a/36011540/6936216)
      packageOverrides = super:
        let self = super.pkgs;
        in {
          alsaLib116 = super.alsaLib.overrideAttrs (oldAttrs: rec {
            name = "alsa-lib-1.1.6";
            src = self.fetchurl {
              url = "mirror://alsa/lib/${name}.tar.bz2";
              sha256 = "096pwrnhj36yndldvs2pj4r871zhcgisks0is78f1jkjn9sd4b2z";
            };
          });
          # audacity is broken because of ALSA lib
          audacity221 =
            (super.audacity.override { alsaLib = self.alsaLib116; }).overrideAttrs
            (oldAttrs: rec {
              version = "2.2.1";
              name = "audacity-${version}";
              src = self.fetchurl {
                url =
                  "https://github.com/audacity/audacity/archive/Audacity-${version}.tar.gz";
                sha256 = "1n05r8b4rnf9fas0py0is8cm97s3h65dgvqkk040aym5d1x6wd7z";
              };
            });
          # TODO use this in latex distribution, too
          # biberFixed = super.biber.overrideAttrs(oldAttrs: rec {
          #   patches = stdenv.lib.optionals (stdenv.lib.versionAtLeast pkgs.perlPackages.perl.version "5.30") [
          #     (pkgs.fetchpatch {
          #       name = "biber-fix-tests.patch";
          #       url = "https://git.archlinux.org/svntogit/community.git/plain/trunk/biber-fix-tests.patch?h=5d0fffd493550e28b2fb81ad114d62a7c9403812";
          #       sha256 = "1ninf46bxf4hm0p5arqbxqyv8r98xdwab34vvp467q1v23kfbhya";
          #     })

          #     (pkgs.fetchpatch {
          #       name = "biber-fix-tests-2.patch";
          #       url = "https://git.archlinux.org/svntogit/community.git/plain/trunk/biber-fix-tests-2.patch?h=5d0fffd493550e28b2fb81ad114d62a7c9403812";
          #       sha256 = "1l8pk454kkm0szxrv9rv9m2a0llw1jm7ffhgpyg4zfiw246n62x0";
          #     })
          #   ];
          # });
          profiledHaskellPackages = self.haskellPackages.override {
            overrides = self: super: {
              mkDerivation = args:
                super.mkDerivation (args // { enableLibraryProfiling = true; });
            };
          };
          # Disable suspending my Bluetooth headset. Combine two things to do this:
          # – https://nixos.wiki/wiki/PulseAudio#Clicking_and_Garbled_Audio_for_Creative_Sound_Cards
          # – https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting#Bluetooth_headset_replay_problems
          # This does not work because Bluetooth support is disabled that way.
          # hardware.pulseaudio.configFile = pkgs.runCommand "default.pa" {} ''
          #   sed 's/^load-module module-suspend-on-idle/#\0/' \
          #     ${pkgs.pulseaudio}/etc/pulse/default.pa > $out
          # '';
          # I think we need an overlay instead:
          # pulseaudio = self.pulseaudio.overrideAttrs {
          # }
          python36Packages = super.python36Packages.override (oldAttrs: rec {
            # tests fail but libraries work(?)
            overrides = self: super: rec {
              pyflakes = super.pyflakes.overrideAttrs (z: rec {
                doCheck = false;
                doInstallCheck = false;
              });
              whoosh = super.whoosh.overrideAttrs (z: rec {
                doCheck = false;
                doInstallCheck = false;
              });
            };
          });
          # TODO 2020-05-12 p7zip is marked as insecure but I'm not sure whether
          # winetricks really always needs it?
          winetricks = super.winetricks.override (oldAttrs : rec {
            p7zip = "";
          });
        };
    };
  };
in


with nixpkgs; {
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
      # chromium
      cura # for the occasional 3D-print
      diffpdf
      docker docker_compose
      dropbox-cli
      emacs
      evince
      firefox
      geeqie
      gimp
      gnuplot
      google-chrome # for DRM-protected streaming
      gparted
      inkscape
      libreoffice
      lilyterm
      lingot # guitar tuner
      # mediathekview # TODO broken
      mpv # much faster than big ol' vlc
      musescore
      openshot-qt # if I ever need to quickly edit video
      signal-desktop
      simplescreenrecorder
      skype # too many people use this -.-
      spotify
      tabula # for extracting tables from PDFs
      tdesktop
      teamviewer # sometimes needed, happy when its already installed
      # thunderbird
      tor-browser-bundle-bin
      vimHugeX # huge b/c want to have gvim around
      vlc # wow, much simple to use, much support
      # NOTE broken due to "error: undefined reference to '__divmoddi4'"
      (nixpkgs20200702.wine) (nixpkgs20200702.winetricks) # always handy to keep around; you never know x)
      zathura
      zoom-us # people make me use this >.<
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
    msmtp
    neomutt
    notmuch
    offlineimap
    urlscan
  ];

  commandline = {
    main = [
      aqbanking
      atool
      bup # backup solution
      cachix # another Nix cache, originally required for installing neuron
      curl
      dfc
      dbacl
      droopy # browser-based file sharing
      exa # a better `ls`
      fd # fast and user-friendly alternative to `find`
      feedgnuplot # stream data to gnu plot for live graphs
      ffmpeg
      fzf # fuzzy file finder
      git
      gitAndTools.git-annex
      gitstats
      nixpkgs20191003.hugo
      nixpkgs20191003.khal # calendar
      khard # contacts
      ledger
      lzip # some people do use LZMA compression
      magic-wormhole
      mr
      # (let neuronRev = "3dd9567febed0e56db38993644258070dc9b1053"; # 2020-06-14
      (let neuronRev = "0b15fdf2a65eccb257423192eb248bfb8eb915a3"; # 2020-08-01
           neuronSrc = builtins.fetchTarball "https://github.com/srid/neuron/archive/${neuronRev}.tar.gz";
        in import neuronSrc {})
      nixpkgs20191003.newsboat # fetches RSS feeds
      nixfmt
      nix-index # builds an index for `nix-locate` which helps me to search my nix-store
      rcm
      # p7zip # TODO as of 2020-05-12 marked as insecure
      pandoc
      (pass.withExtensions (ext: with ext; [ pass-otp pass-update ]))
      pdftk
      timidity # for playing the occasional MIDI file
      transmission
      tree
      unrar
      unzip
      # vdirsyncer # TODO need to overwrite stuff (see user config.nix)
      weechat
      zip
    ];
    utility = [
      acpi # for a more nicely formatted battery status in conky
      bind # for the occasional `dig`
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
      ripgrep
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
    # Haskell development
    binutils # I sometimes need `ar` for building Haskell stuff
    cabal2nix
    cabal-install
    # (haskellPackages.ghcWithPackages(ps:
    #   with ps; [
    #     protolude
    #     optparse-applicative
    #     # this does not work
    #     nixpkgs20200702.haskellPackages.random-fu # [2020-08-11] broken in master
    #     random
    #     text
    #     turtle
    #   ]
    # ))
    (nixpkgs20200702.haskellPackages.ghcWithPackages(ps: # [2020-08-11] random-fu broken in master
      with ps; [
        protolude
        optparse-applicative
        random-fu
        # nixpkgs20200702.haskellPackages.random # [2020-08-11] broken in master
        random
        text
        turtle
      ]
    ))
    # haskellPackages.ghc-mod # TODO currently not working
    haskellPackages.hlint
    # haskellPackages.lhs2tex # TODO not working
    stack

    # Python development
    autoflake
    (python37.withPackages(ps:
      with ps; [
        click
        matplotlib
        numpy
        seaborn
        pandas
        scikitlearn
      ]
    ))
    python37Packages.isort
    python37Packages.yapf

    # Everything else
    automake autoconf # always annoying when these are needed but not available
    cloc
    # elmPackages.elm # TODO currently not working
    gcc
    gdb # sometimes you just need it
    gnumake
    openjdk
    patchelf # so handy
    R
    ruby
    sbt
    scala
    shellcheck
    weka
  ];
}
