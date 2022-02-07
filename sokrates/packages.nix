{ pkgs, inputs, ... }:

{

  # TODO Why do I have to do this here as well? Why doesn't it suffice to do
  # this when I `import nixpkgs` in flake.nix?
  nixpkgs.config = {
    android_sdk.accept_license = true;
    oraclejdk.accept_license = true;
    allowUnfree = true;
    chromium.pulseSupport = true;
  };

  environment.systemPackages = with pkgs;
    let
      system = [ cryptsetup ntfs3g ];
      applications = {
        main = [
          androidenv.androidPkgs_9_0.androidsdk
          audacity
          lame
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
          lingot # guitar tuner
          kitty # terminal emulator
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

      mutt = [ elinks msmtp neomutt notmuch offlineimap urlscan ];

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
          hledger # accounting made nicer
          hugo
          inotify-tools
          khal # calendar
          khard # contacts
          ledger # accounting made nice
          lzip # some people do use LZMA compression
          magic-wormhole
          mr
          mosh # less laggy than SSH
          # (let neuronRev = "3dd9567febed0e56db38993644258070dc9b1053"; # 2020-06-14
          # (let neuronRev = "0b15fdf2a65eccb257423192eb248bfb8eb915a3"; # 2020-08-01
          # (let neuronRev = "8d9bc7341422a2346d8fd6dc35624723c6525f40"; # 2021-01-13
          # (let neuronRev = "24cf8eb5e23776645afc036efc9c660fd4c60fdb"; # 2021-03-10
          # (let neuronRev = "164956fdab8242b78e6c51753aa3d2f0b3fdc2fc"; # 2021-05-31
          #      neuronSrc = builtins.fetchTarball "https://github.com/srid/neuron/archive/${neuronRev}.tar.gz";
          #      neuronPkg = import neuronSrc;
          #   in neuronPkg.default)
          neuron
          # (let emanoteRev = "158fda842134bab25ee15eda239cc599b0982e7b"; # 2021-08-08
          #      emanoteSrc = builtins.fetchTarball "https://github.com/srid/emanote/archive/${emanoteRev}.tar.gz";
          #      emanotePkg = import emanoteSrc;
          #   in emanotePkg.default)
          newsboat # fetches RSS feeds
          nixfmt
          nix-index # builds an index for `nix-locate` which helps me to search my nix-store
          rcm
          p7zip
          pandoc
          (pass.withExtensions (ext: with ext; [ pass-otp pass-update ]))
          pdftk
          qrencode # for creating the occasional QR code
          # signal-cli
          # teamspeak_client
          tigervnc # somehow this works best for me
          timidity # for playing the occasional MIDI file
          transmission
          tree
          unison
          unrar
          unzip
          vdirsyncer
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
        (haskellPackages.ghcWithPackages
          (ps: # [2020-08-11] random-fu broken in master
            with ps; [
              # protolude
              optparse-applicative
              random-fu
              # nixpkgs20200702.haskellPackages.random # [2020-08-11] broken in master
              random
              text
              # turtle
            ]))
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
        python39Packages.yapfToml

        # Purescript development
        nodejs
        nodePackages.parcel-bundler
        pscid
        purescript
        spago

        # LaTeX
        (with texlive;
          combine {
            inherit biblatex biblatex-ieee capt-of inconsolata libertine logreq
              newtx scheme-full wrapfig xstring;
          })
        biber

        # Everything else
        automake
        autoconf # always annoying when these are needed but not available
        cloc
        gcc
        gdb # sometimes you just need it
        gnumake
        netlogo
        # openjdk
        patchelf # so handy
        # R
        # ruby
        # sbt
        # scala
        shellcheck
        # weka
      ];

    in system ++ applications.main ++ applications.utility
    ++ graphical-user-interface ++ mutt ++ commandline.main
    ++ commandline.utility ++ development;
}
