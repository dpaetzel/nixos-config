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
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    extraHosts = ''
      192.168.0.10 anaxagoras
    '';
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
    emacs
    rxvt_unicode-with-plugins
    # firefox
    vimb
    chromium
    cacert
    zathura
    vim
    vlc

    # utility applications
    arandr
    pavucontrol
    slock
    xorg.xev
    scrot
    feh

    # graphical user interface
    redshift
    unclutter
    xcompmgr
    dzen2
    conky
    dunst
    dmenu2
    networkmanagerapplet

    # e-mail
    mutt
    offlineimap
    msmtp
    gnupg
    elinks
    # urlview

    # main cli programs
    fish
    rcm
    kbd
    git
    gitAndTools.git-annex

    # utility cli programs
    htop
    wget
    curl
    psmisc
    which
    zip
    pmount
    zsh
    silver-searcher
    bc
    file
    man_db

    # development
    scala
    sbt
    gcc
    gnumake
    ghc
    ruby
  ];

  # Enable proper backlight management.
  programs.light.enable = true;

  # Enable pulseaudio.
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "neo";
    synaptics = {
      enable = true;
      twoFingerScroll = true;
      # TODO add other options
    };
    displayManager.slim.defaultUser = "david";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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
}
