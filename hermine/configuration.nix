{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common.nix
    ];

  # Networking.
  networking.hostName = "hermine";

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
    consoleKeyMap = "de";
    defaultLocale = "de_DE.UTF-8";
  };

  environment.systemPackages = with pkgs; [ TODO ];

  nixpkgs.config = {
    allowUnfree = true;

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

