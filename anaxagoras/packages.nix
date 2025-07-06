{
  inputs,
  pkgs,
  system,
  ...
}:

# TODO De-duplicate this with sokrates/packages.nix

{

  environment.systemPackages =
    with pkgs;
    let
      sys = [
        cryptsetup
        ntfs3g
      ];
      applications = {
        main = [
          # anaxagoras-only
          glxinfo

          android-tools
          audacity
          lame
          # chromium
          # cura # for the occasional 3D-print
          diffpdf
          digikam # let's try this for non-hierarchical management of photos
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
          gparted exfat exfatprogs
          inkscape
          libreoffice
          lingot # guitar tuner
          kitty # terminal emulator
          makemkv
          mpv # much faster than big ol' vlc
          musescore
          obsidian # I was finally broken and switched to the dark side
          # TODO Disable emanote and neuron and their services
          openshot-qt # if I ever need to quickly edit video
          signal-desktop
          simplescreenrecorder
          skypeforlinux # too many people use this -.-
          spotify
          steamcmd
          steam-tui
          # tabula # for extracting tables from PDFs
          tdesktop # some people still use Telegram
          # teams # people make me use this >.< but its not supported for x86_64-linux anyways
          threema-desktop # Threema is OK I guess
          # teamviewer # sometimes needed, happy when its already installed
          # thunderbird
          # tor-browser-bundle-bin
          vimHugeX # huge b/c want to have gvim around
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
        # emote # emojis make my life brighter 😊 but `smile` seems a bit nicer maybe, we'll see
        libnotify
        lxappearance
        networkmanagerapplet
        picom
        smile # emojis make my life brighter 😊
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
          autossh # for the occasional SSH tunnel which should be kept open
          # aqbanking
          atool
          # (haskellPackages.arbtt)
          # beancount # accounting made even nicer than (h)ledger? I install
          # that in the Flake though
          beancount-black # formatter for beancount
          # fava # web interface for beancount
          bup # backup solution
          cachix # another Nix cache, originally required for installing neuron
          curl
          direnv
          nix-direnv
          dbacl
          dfc
          # droopy # browser-based file sharing
          dos2unix # people sometimes send me bad files
          eza # a better `ls`
          fdupes # finding duplicates
          fd # fast and user-friendly alternative to `find`
          feedgnuplot # stream data to gnu plot for live graphs
          ffmpeg
          fishPlugins.done # notify me of long-running jobs
          # TODO Move this to home-manager (enable fzf and its fishIntegration)
          fishPlugins.fzf-fish
          fishPlugins.autopair # add a ) when you type (
          fishPlugins.puffer # auto expand ... etc.
          fishPlugins.grc
          grc # colorize output
          fzf # fuzzy file finder
          git
          gitAndTools.git-annex
          gitstats
          hledger # accounting made nicer
          hugo
          inotify-tools
          jq # command line json query tool
          # khal # calendar
          # khard # contacts
          ledger # accounting made nice
          libcgroup # the occasional process limits using cgcreate and friends
          lzip # some people do use LZMA compression
          # magic-wormhole
          mr
          mosh # less laggy than SSH
          # While I started using emanote my Emacs stuff still relies on neuron
          inputs.neuron.outputs.defaultPackage."${system}" # Zettelkasten ftw
          emanote # Zettelkasten ftw
          # inputs.emanote.packages."${system}".default # Zettelkasten ftw
          # newsboat # fetches RSS feeds
          nixfmt-rfc-style
          nix-index # builds an index for `nix-locate` which helps me to search my nix-store
          ocrmypdf # super useful for scanned stuff
          p7zip
          pandoc
          (pass.withExtensions (
            ext: with ext; [
              pass-otp
              pass-update
            ]
          ))
          pciutils
          pdftk
          qrencode # for creating the occasional QR code
          rclone # for syncing encrypted content to The Cloud
          rcm
          # signal-cli
          socat
          sshfs
          tesseract # image to text
          # teamspeak_client
          tigervnc # somehow this works best for me
          timidity # for playing the occasional MIDI file
          transmission
          tree
          unison
          units
          unrar
          unzip
          # vdirsyncer
          wally-cli # for flashing my flashy keyboard
          # weechat
          # whisper-cpp # audio to text
          zip
        ];
        utility = [
          abduco # Detach from commands and reattach later.
          acpi # for a more nicely formatted battery status in conky
          bind # for the occasional `dig`
          cifs-utils
          coreutils
          dosfstools
          entr # will be replaced by watchexec, I guess?
          file
          ghostscript
          htop
          imagemagick
          inetutils # telnet and friends
          ffmpeg
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
          watchexec # monitor for changes and do stuff
          wget
          # wirelesstools
          which
          whois
          # youtube-dl # Does not work reliably, currently using ytmdl instead
          xclip
        ];
      };

      development = [
        # Julia development
        myjulia
        # This withPackages stuff is fairly new to nixpkgs and seems still
        # somewhat broken. It is likely the reason for the many annoying
        # recompiles I observe, presumably due to interference with projects
        # managed using Julia's Pkg. Also, some things just don't work (e.g.
        # building system images or native executables).
        # (julia_110-bin.withPackages.override
        #   {
        #     extraLibs = [];
        #     # GLMakie requires the opengl-driver path.
        #     makeWrapperArgs = "--prefix LD_LIBRARY_PATH : /run/opengl-driver/lib";
        #   }
        #   [
        #     "AlgebraOfGraphics"
        #     "BenchmarkTools"
        #     "CairoMakie"
        #     "DataFrames"
        #     "DataFramesMeta"
        #     "Distributions"
        #     # Not working due to ERROR: LoadError: InitError:
        #     # Exception[GLFW.GLFWError(65550, "Failed to detect any supported
        #     # platform"), ErrorException("glfwInit failed")]
        #     # "GLMakie"
        #     "Infiltrator"
        #     "OhMyREPL"
        #     "Statistics"
        #     "StatsBase"
        #   ]
        # )

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
        (haskellPackages.ghcWithPackages (
          ps: # [2020-08-11] random-fu broken in master
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
        mypython
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
        mypython.pkgs.black
        mypython.pkgs.isort
        mypython.pkgs.mypy
        mypython.pkgs.pyflakes
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
        (
          with texlive;
          combine {
            inherit
              biblatex
              biblatex-ieee
              capt-of
              inconsolata
              libertine
              logreq
              newtx
              scheme-full
              wrapfig
              xstring
              ;
          }
        )
        biber
        pplatex # supposedly better logs

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

      creativity = [
        # We don't need qjackctl because jack runs as a systemd service already
        # (and we don't need to start a new jack server).
        # patchage
        # PipeWire graph stuff.
        helvum # Acc. to the pipewire repository, this should be the patchbay of choice.
        qpwgraph
        wireplumber
        pulseaudio # For pactl and other sound debugging equipment.
        alsa-utils # For aplay and other sound debugging equipment.

        # https://github.com/NixOS/nixpkgs/issues/293315
        kdePackages.kdenlive # openshot-qt is super buggy but we still want to edit videos sometimes.
        # flowblade # Maybe flowblade > kdenlive? However, flowblade segfaults
        # upon startup on 2023-11-03.

        # daw
        ardour

        # synthesizers
        zynaddsubfx

        # effects
        calf
        lsp-plugins
        mooSpace
        talentedhack
        x42-plugins

        # eqs/filters
        eq10q

        # samplers
        drumkv1
        drumgizmo

        # pitch shifters
        # MaPitchshift
      ];

    in
    sys
    ++ applications.main
    ++ applications.utility
    ++ graphical-user-interface
    ++ mutt
    ++ commandline.main
    ++ commandline.utility
    ++ development
    ++ creativity;
}
