{ config, pkgs, ... }:

{
  imports =
    [ # include the results of the hardware scan
      ./hardware-configuration.nix
      ../common.nix
    ];

  networking.hostName = "cleopatra";
  # disable the internal wifi-card as it interfers with the USB one
  networking.networkmanager.unmanaged = [ "mac:40:f0:2f:57:6b:47" ];

  users.extraUsers.regine = {
    shell = "${pkgs.zsh}/bin/zsh";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # mount the home partition
  fileSystems."/home" =
    { device = "/dev/sda9";
      fsType = "ext4";
    };

  # use the gummiboot efi boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  i18n = {
    consoleKeyMap = "neo";
    defaultLocale = "de_DE.UTF-8";
  };

  services.xserver = {
    layout = "de,de";
    xkbVariant = "neo,";
    xkbOptions = "grp:ctrl_shift_toggle,terminate:ctrl_alt_bksp";
    # synaptics = {
    #   enable = true;
    #   twoFingerScroll = true;
    # };
    videoDrivers = [ "mesa" ];

    # displayManager.slim.defaultUser = "regine";
    displayManager.lightdm.enable = true;
    desktopManager.gnome3.enable = true;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  nixpkgs.config.chromium.gnomeSupport = true;

  environment.systemPackages =
    with (import ../packages.nix pkgs);
      system ++
      applications.main ++
      commandline.main;
}
