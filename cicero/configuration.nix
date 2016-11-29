{ config, pkgs, ... }:

{
  imports =
    [ # include the results of the hardware scan
      ./hardware-configuration.nix
      ../common.nix
    ];

  networking.hostName = "cicero";

  users.extraUsers.oldies = {
    shell = "${pkgs.zsh}/bin/zsh";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # TODO
  # mount the home partition
  # fileSystems."/home" =
  #   { device = "/dev/sda9";
  #     fsType = "ext4";
  #   };

  # TODO
  # use the gummiboot efi boot loader
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  i18n = {
    consoleKeyMap = "neo";
    defaultLocale = "de_DE.UTF-8";
  };

  services.xserver = {
    layout = "de,de";
    xkbVariant = ",neo";
    xkbOptions = "grp:ctrl_shift_toggle,terminate:ctrl_alt_bksp";
    # videoDrivers = [ "mesa" ]; # TODO

    displayManager.lightdm.enable = true;
    desktopManager.gnome3.enable = true;
  };

  # TODO
  # services.printing = {
  #   enable = true;
  #   drivers = [ pkgs.gutenprint ];
  # };

  environment.systemPackages =
    with (import ../packages.nix pkgs);
      system ++
      applications.main ++
      commandline.main
}
