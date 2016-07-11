{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.opengl.driSupport32Bit = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "neo";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Networking.
  networking = {
    hostName = "heraklit"; # Define your hostname.
    networkmanager.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.basePackages =
      with pkgs; {
        # the openssl backend doesn’t like the protocols of my university
        networkmanager_openconnect =
          pkgs.networkmanager_openconnect.override { openconnect = pkgs.openconnect_gnutls; };
        inherit networkmanager modemmanager wpa_supplicant
                networkmanager_openvpn networkmanager_vpnc
                networkmanager_pptp networkmanager_l2tp;
    };
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    extraHosts = ''
      192.168.0.10 anaxagoras
    '';
    firewall.enable = false;
  };

  # Installed fonts.
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      cm_unicode
      corefonts
      dejavu_fonts
      inconsolata
      # ipafont
      kochi-substitute
      source-code-pro
      symbola
      terminus_font
      ubuntu_font_family
      unifont
      vistafonts
    ];
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # main applications
    anki
    chromium
    # cutegram
    emacs
    # firefox
    libreoffice
    lilyterm
    # rxvt_unicode-with-plugins
    vim
    vlc
    zathura

    # utility applications
    arandr
    feh
    gimp
    pavucontrol
    scrot
    slock
    trayer
    xorg.xev
    xdotool

    # graphical user interface
    conky
    dmenu2
    dunst
    dzen2
    libnotify
    lxappearance
    networkmanagerapplet
    parcellite
    redshift
    unclutter
    xcompmgr

    # numix-gtk-theme
    # numix-icon-theme
    # elementary-icon-theme
    # gtk-engine-murrine
    # arc-gtk-theme

    # e-mail
    elinks
    gnupg
    msmtp
    mutt
    offlineimap
    urlview

    # main cli programs
    fish
    git
    gitAndTools.git-annex
    rcm
    weechat
    python27Packages.turses
    zsh

    # utility cli programs
    dosfstools
    file
    htop
    manpages
    pmount
    psmisc
    (nmap.override { graphicalSupport = true; })
    silver-searcher
    telnet
    tmux
    traceroute
    wget curl
    which

    # archive managment
    atool
    unzip
    zip

    # misc
    cacert
    kbd
    networkmanager_openconnect

    # development
    gcc
    ghc
    gnumake
    ruby
    sbt
    scala
  ];

  nixpkgs.config = {
    allowUnfree = true;

    # firefox = {
    #   enableGoogleTalkPlugin = true;
    #   enableAdobeFlash = true;
    # };

    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };
  };

  # Enable proper backlight management.
  programs.light.enable = true;

  # Enable pulseaudio.
  hardware.pulseaudio.enable = true;

  # Enable fast searching for files.
  services.locate.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "neo";
    synaptics = {
      enable = true;
      twoFingerScroll = true;
    };
    videoDrivers = [ "intel" ];

    displayManager.slim.defaultUser = "david";

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };

    startGnuPGAgent = true;
  };

  # Must be disabled for GnuPGAgent to work.
  programs.ssh.startAgent = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.david = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

  # The encrypted partition.
  boot.initrd.luks.devices = [
    { name = "crypted";
      device = "/dev/sda3";
      preLVM = true;
    }
  ];

  # Automatically upgrade once a day.
  system.autoUpgrade.enable = true;

  # Generate setuid wrappers.
  security.setuidPrograms = [
    "pmount"
    "slock"
  ];
}
