{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Mount the home partition.
  fileSystems."/home" =
    { device = "/dev/sda9";
      fsType = "ext4";
    };

  # Use the gummiboot efi boot loader.
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";
    defaultLocale = "de_DE.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Networking.
  networking = {
    hostName = "hermine"; # Define your hostname.
    networkmanager.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
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
    firefox
    chromium
    cacert
    emacs
    vim
    vlc

    # e-mail
    thunderbird
    gnupg

    # main cli programs
    fish
    git

    # utility cli programs
    htop
    wget
    curl
    psmisc
    which
    zip
    pmount
    file
    man_db
    # zsh
    # silver-searcher
    # bc
  ];

  nixpkgs.config = {
    allowUnfree = true;

    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
    };

    chromium = {
      enablePepperFlash = true; # Chromium removed support for Mozilla (NPAPI) plugins so Adobe Flash no longer works
      enablePepperPDF = true;
    };
  };

  # Enable pulseaudio.
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "de";
    # xkbVariant = "neo";
    synaptics = {
      enable = true;
      twoFingerScroll = true;
      # TODO add other options
    };
    # displayManager.slim.defaultUser = "regine";
    desktopManager.gnome3.enable = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.regine = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

  # Automatically upgrade once a day.
  system.autoUpgrade.enable = true;
}
