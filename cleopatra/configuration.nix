{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common.nix
    ];

  networking.hostName = "cleopatra";

  users.extraUsers.regine = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Mount the home partition.
  fileSystems."/home" =
    { device = "/dev/sda9";
      fsType = "ext4";
    };

  # Use the gummiboot efi boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  i18n = {
    consoleKeyMap = "de";
    defaultLocale = "de_DE.UTF-8";
  };

  services.xserver = {
    layout = "de";
    # xkbVariant = "neo";
    # synaptics = {
    #   enable = true;
    #   twoFingerScroll = true;
    # };
    displayManager.slim.defaultUser = "regine";
    desktopManager.gnome3.enable = true;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  environment.systemPackages =
    with (import ../packages.nix pkgs);
      system ++
      applications.main ++
      commandline.main ++
      [
        cutegram
      ];
}
