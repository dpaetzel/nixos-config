{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common.nix
    ];

  networking.hostName = "anaxagoras";

  users.extraUsers.david = {
    shell = "${pkgs.zsh}/bin/zsh";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # the encrypted partition
  boot.initrd.luks.devices = [
    { name = "DecryptedHome";
      device = "/dev/mapper/LinuxData-Home";
      # preLVM = true;
    }
  ];

  # use the gummiboot efi boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  i18n = {
    consoleKeyMap = "neo";
    defaultLocale = "en_US.UTF-8";
  };

  services.xserver = {
    layout = "de";
    xkbVariant = "neo";
    # videoDrivers = [ "intel" ];

    displayManager.slim.defaultUser = "david";

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
    # otherwise an xterm spawns the window manager(?!?)
    desktopManager.xterm.enable = false;
  };

  # other services
  services.openssh.enable = true;
  services.tlp.enable = true; # power management/saving for laptops
  # “A list of files containing trusted root certificates in PEM format. These
  # are concatenated to form /etc/ssl/certs/ca-certificates.crt”
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];

  security.setuidPrograms = [
    "pmount"
    "slock"
  ];

  networking.networkmanager.basePackages =
    with pkgs; {
      # needed for university vpn; thanks Profpatsch!
      networkmanager_openconnect =
        pkgs.networkmanager_openconnect.override { openconnect = pkgs.openconnect_gnutls; };
      inherit networkmanager modemmanager wpa_supplicant
              networkmanager_openvpn networkmanager_vpnc
              networkmanager_pptp networkmanager_l2tp;
  };
  # networking.wireless.enable = true;  # wireless support via wpa_supplicant

  environment.systemPackages =
    with (import ../packages.nix pkgs);
      system ++
      applications.main ++
      applications.utility ++
      graphical-user-interface ++
      mutt ++
      commandline.main ++
      commandline.utility ++
      development ++
      (with pkgs; [
      # other pkgs
      ]);
}
