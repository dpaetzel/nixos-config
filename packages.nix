pkgs :


let
  nixpkgs20191003 = import (builtins.fetchGit {
    name = "nixpkgs-2019-10-03";
    url = https://github.com/NixOS/nixpkgs/;
    rev = "406335aeb139ca5510c724c730e4f5ea83ad8cf3";
  }) {};
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
  # nixpkgs = import (builtins.fetchGit {
  #   name = "nixpkgs-2020-03-10";
  #   url = https://github.com/NixOS/nixpkgs/;
  #   rev = "cabe2e2e55f9e5220c99b424d23800605cfa5f17";
  # }) {
  # nixpkgs = import (builtins.fetchGit {
  #   name = "nixpkgs-2021-05-30";
  #   url = https://github.com/NixOS/nixpkgs/;
  #   rev = "774fe1878b045411e6bdd0dd90d8581e82b10993";
  # }) {
  # never got to use this version due to space problems
  # nixpkgs = import (builtins.fetchGit {
  #   name = "nixpkgs-2021-08-04";
  #   url = https://github.com/NixOS/nixpkgs/;
  #   rev = "5310ebc9d2cf5046af495738f49bc384d6065800";
  # }) {
  nixpkgs = import (builtins.fetchGit {
    name = "nixpkgs-2021-12-09";
    url = https://github.com/NixOS/nixpkgs/;
    rev = "9244ce07fe088c226ab693c4cf2641f50aaf25bb";
  }) {
    overlays = [
      (final: prev: {
        myyapf = prev.python3Packages.yapf.overridePythonAttrs( old : rec {
          propagatedBuildInputs = [ prev.python3Packages.toml ];
        });
      })
    ];

    config = {
      android_sdk.accept_license = true;
      oraclejdk.accept_license = true;
      allowUnfree = true;

      chromium.pulseSupport = true;

      permittedInsecurePackages = [
        # TODO I'm not sure yet which package requires this, we probably just
        # want to remove that then
        "spidermonkey-38.8.0"
      ];

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
      # abcde # for occasionally ripping CDs
      # adobe-reader # for occasionally having to read comments in PDFs [2020-10-02] marked as insecure
      androidenv.androidPkgs_9_0.androidsdk
      audacity lame
      # chromium
      # cura # for the occasional 3D-print
      diffpdf
      # discord # some people force me to use this
      # docker docker_compose
      # dropbox-cli
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
      # openshot-qt # if I ever need to quickly edit video
      signal-desktop
      simplescreenrecorder
      skype # too many people use this -.-
      spotify
      tabula # for extracting tables from PDFs
      tdesktop
      # teamviewer # sometimes needed, happy when its already installed
      # thunderbird
      # tor-browser-bundle-bin
      vimHugeX # huge b/c want to have gvim around
      vlc # wow, much simple to use, much support
      # NOTE broken due to "error: undefined reference to '__divmoddi4'"
      # (nixpkgs20200702.wine) (nixpkgs20200702.winetricks) # always handy to keep around; you never know x)
      # (nixpkgs20200702.wine.override { wineBuild = "wine64"; }) (nixpkgs20200702.winetricks) # always handy to keep around; you never know x)
      xournal # for annotating PDFs (e.g. for signing stuff)
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
      xdotool
      xvkbd # required for my version of passmenu
      xorg.xev
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
      (haskellPackages.arbtt)
      bup # backup solution
      cachix # another Nix cache, originally required for installing neuron
      curl
      dfc
      dbacl
      # droopy # browser-based file sharing
      dos2unix # people sometimes send me bad files
      exa # a better `ls`
      fdupes # finding duplicates
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
      mosh # less laggy than SSH
      # (let neuronRev = "3dd9567febed0e56db38993644258070dc9b1053"; # 2020-06-14
      # (let neuronRev = "0b15fdf2a65eccb257423192eb248bfb8eb915a3"; # 2020-08-01
      # (let neuronRev = "8d9bc7341422a2346d8fd6dc35624723c6525f40"; # 2021-01-13
      # (let neuronRev = "24cf8eb5e23776645afc036efc9c660fd4c60fdb"; # 2021-03-10
      (let neuronRev = "164956fdab8242b78e6c51753aa3d2f0b3fdc2fc"; # 2021-05-31
           neuronSrc = builtins.fetchTarball "https://github.com/srid/neuron/archive/${neuronRev}.tar.gz";
           neuronPkg = import neuronSrc;
        in neuronPkg.default)
      # (let emanoteRev = "158fda842134bab25ee15eda239cc599b0982e7b"; # 2021-08-08
      #      emanoteSrc = builtins.fetchTarball "https://github.com/srid/emanote/archive/${emanoteRev}.tar.gz";
      #      emanotePkg = import emanoteSrc;
      #   in emanotePkg.default)
      nixpkgs20191003.newsboat # fetches RSS feeds
      nixfmt
      nix-index # builds an index for `nix-locate` which helps me to search my nix-store
      rcm
      # p7zip # TODO as of 2020-05-12 marked as insecure
      pandoc
      (pass.withExtensions (ext: with ext; [ pass-otp pass-update ]))
      pdftk
      qrencode # for creating the occasional QR code
      # teamspeak_client
      tigervnc # somehow this works best for me
      timidity # for playing the occasional MIDI file
      transmission
      tree
      unrar
      unzip
      # vdirsyncer # TODO need to overwrite stuff (see user config.nix)
      wally-cli # for flashing my flashy keyboard
      # weechat
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
      # pastebinit
      pdfgrep
      pmount
      poppler_utils
      # powertop
      psmisc
      pv
      python3Packages.pygments
      quvi # flash video scraper/getter/…
      ripgrep
      telnet
      tmux
      traceroute
      usbutils
      veracrypt
      wget
      # wirelesstools
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
        # protolude
        optparse-applicative
        random-fu
        # nixpkgs20200702.haskellPackages.random # [2020-08-11] broken in master
        random
        text
        # turtle
      ]
    ))
    ormolu
    # haskellPackages.ghc-mod # TODO currently not working
    haskellPackages.hlint
    # haskellPackages.lhs2tex # TODO not working
    # stack

    # Python development
    autoflake
    python3
    # (python3.withPackages(ps:
    #   with ps; [
    #     click
    #     ipython
    #     matplotlib
    #     numpy
    #     pandas
    #     scikitlearn
    #     seaborn
    #   ]
    # ))
    python3Packages.isort
    python3Packages.mypy
    python3Packages.pyflakes
    myyapf

    # Purescript development
    nodejs
    nodePackages.parcel-bundler
    pscid
    purescript
    spago

    # Everything else
    automake autoconf # always annoying when these are needed but not available
    cloc
    gcc
    gdb # sometimes you just need it
    gnumake
    # openjdk
    patchelf # so handy
    # R
    # ruby
    # sbt
    # scala
    shellcheck
    # weka
  ];
}
