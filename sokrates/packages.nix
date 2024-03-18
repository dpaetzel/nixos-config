{ inputs, pkgs, system, ... }:

{

  environment.systemPackages = with pkgs;
    let
      sys = [ cryptsetup ntfs3g ];
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
          font-manager
          # firefox # installed via programs.firefox.enable
          geeqie
          gimp
          # gnome.gnome-calendar # maybe a better calendar app? no, bloaty, have
          # to do additional things and services for it to work
          gnuplot
          google-chrome # for DRM-protected streaming
          gparted
          # hplipWithPlugin # not working for us as of 2024-01
          inkscape # vector graphics
          libreoffice
          lingot # guitar tuner
          kitty # terminal emulator
          # morgen # better calendar app?
          mpv # much faster than big ol' vlc
          musescore
          obs-studio
          openshot-qt # if I ever need to quickly edit video # Somehow no audio gets exported
          portfolio # aka Portfolio Performance.
          pympress # giving talks with beamer slides was never more pleasant
          signal-desktop
          simplescreenrecorder
          # skypeforlinux # too many people use this -.-
          spotify
          # tabula # for extracting tables from PDFs
          # tdesktop # some people still use Telegram
          tridactyl-native # For a better browser.
          # threema-desktop # Threema is OK I guess # installed in user env
          # teamviewer # sometimes needed, happy when its already installed
          thunderbird # not the best but also not the worst I guess
          # tor-browser-bundle-bin
          # vimHugeX # huge b/c want to have gvim around
          vim # huge b/c want to have gvim around
          virt-manager # replacement for VirtualBox, more lightweight
          vlc # wow, much simple to use, much support
          # NOTE broken due to "error: undefined reference to '__divmoddi4'"
          # (nixpkgs20200702.wine) (nixpkgs20200702.winetricks) # always handy to keep around; you never know x)
          # (nixpkgs20200702.wine.override { wineBuild = "wine64"; }) (nixpkgs20200702.winetricks) # always handy to keep around; you never know x)
          xournal # for annotating PDFs (e.g. for signing stuff)
          zathura # for viewing PDFs
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
        dmenu
        dunst
        dzen2
        libnotify
        lxappearance
        networkmanagerapplet
        picom
        # setroot # build broken as of 2022-04-05
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
          # aqbanking
          atool
          # (haskellPackages.arbtt)
          bup # backup solution
          cachix # another Nix cache, originally required for installing neuron
          curl
          # dbacl
          dfc
          # direnv nix-direnv
          # droopy # browser-based file sharing
          dos2unix # people sometimes send me bad files
          espeak # for when I can't speak
          eza # a better `ls`
          fdupes # finding duplicates
          fd # fast and user-friendly alternative to `find`
          feedgnuplot # stream data to gnu plot for live graphs
          ffmpeg
          fishPlugins.done # notify me of long-running jobs
          fishPlugins.fzf-fish
          fishPlugins.autopair # add a ) when you type (
          fishPlugins.puffer # auto expand ... etc.
          fishPlugins.grc grc # colorize output
          fzf # fuzzy file finder
          git
          gitAndTools.git-annex
          gitstats
          hledger # accounting made nicer
          hugo
          inotify-tools
          jq # command line json query tool
          khal # calendar
          khard # contacts
          ledger # accounting made nice
          lzip # some people do use LZMA compression
          magic-wormhole
          mr
          mosh # less laggy than SSH
          # While I started using emanote my Emacs stuff still relies on neuron
          inputs.neuron.outputs.defaultPackage."${system}" # Zettelkasten ftw
          # inputs.emanote.packages."${system}".default # Zettelkasten ftw
          # newsboat # fetches RSS feeds
          nixfmt
          nix-index # builds an index for `nix-locate` which helps me to search my nix-store
          rclone # for syncing encrypted content to The Cloud
          rcm
          p7zip
          pandoc
          (pass.withExtensions (ext: with ext; [ pass-otp pass-update ]))
          pdftk
          qrencode # for creating the occasional QR code
          # signal-cli
          socat
          sshfs
          starship # Better prompts.
          # teamspeak_client
          # tigervnc # somehow this works best for me
          timidity # for playing the occasional MIDI file
          # transmission
          todoman # Manage todos synced via CalDAV/vdirsyncer.
          tree
          unison
          units
          unrar
          unzip
          vdirsyncer
          wally-cli # for flashing my flashy keyboard
          # weechat
          zip
        ];
        utility = [
          abduco # Detach from commands and reattach later.
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
          inetutils # telnet and friends
          lm_sensors
          lsof
          man-pages
          nix-prefetch-git
          nix-zsh-completions
          nmap
          # pastebinit
          pdfgrep
          # pmount
          poppler_utils
          # powertop
          psmisc
          pv
          python3Packages.pygments
          ripgrep
          tmux # Probably suboptimal, use abduco instead?
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
        # binutils # I sometimes need `ar` for building Haskell stuff
        # cabal2nix
        # cabal-install
        # # (haskellPackages.ghcWithPackages(ps:
        # #   with ps; [
        # #     protolude
        # #     optparse-applicative
        # #     # this does not work
        # #     nixpkgs20200702.haskellPackages.random-fu # [2020-08-11] broken in master
        # #     random
        # #     text
        # #     turtle
        # #   ]
        # # ))
        # (haskellPackages.ghcWithPackages
        #   (ps: # [2020-08-11] random-fu broken in master
        #     with ps; [
        #       # protolude
        #       optparse-applicative
        #       random-fu
        #       # nixpkgs20200702.haskellPackages.random # [2020-08-11] broken in master
        #       random
        #       text
        #       # turtle
        #     ]))
        # ormolu
        # # haskellPackages.ghc-mod # TODO currently not working
        # haskellPackages.hlint
        # # haskellPackages.lhs2tex # TODO not working
        # # stack

        # Julia development
        julia-bin
        pprof # View profiling data in Google's pprof format (e.g. using PProf.jl).

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
        python3Packages.black
        python3Packages.isort
        python3Packages.mypy
        python3Packages.pyflakes
        # python3Packages.poetry
        # python39Packages.yapfToml
        # inputs.mach-nix.defaultPackage."${system}"

        # Purescript development
        nodejs
        nodePackages.parcel-bundler
        pscid
        purescript
        # spago # build broken as of 2022-04-05

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
        just
        # netlogo
        # openjdk
        patchelf # so handy
        # R
        # ruby
        # sbt
        # scala
        shellcheck
        # weka
      ];


      #! nix-shell -i python -p "python39.withPackages(ps: with ps; [ click ipython numpy (opencv4.override({ enableFfmpeg = true; enableGtk3 = true; })) tqdm ])"

    in sys ++ applications.main ++ applications.utility
    ++ graphical-user-interface ++ mutt ++ commandline.main
    ++ commandline.utility ++ development;
}
