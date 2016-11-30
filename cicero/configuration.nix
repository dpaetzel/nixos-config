{ config, pkgs, ... }:

{
  imports =
    [
      ../common.nix
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  networking.hostName = "cicero";

  users.extraUsers.oldies = {
    shell = "${pkgs.zsh}/bin/zsh";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "networkmanager"
    ];
  };

  fileSystems."/" =
    # { device = "/dev/disk/by-uuid/92722498-cbaf-4372-bd11-af2c5dc96a4d";
    { device = "/dev/disk/by-label/NixOSRoot";
      fsType = "ext4";
    };

  fileSystems."/home" =
    # { device = "/dev/disk/by-uuid/a9a43c83-b81e-479a-9561-5877b28ac8bf";
    { device = "/dev/disk/by-label/Home";
      fsType = "ext4";
    };

  swapDevices =
    # [ { device = "/dev/disk/by-uuid/f7545cfe-e110-4c16-92f3-f2cbcb93c8b3"; }
    [ { device = "/dev/disk/by-label/Swap"; }
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # define on which hard drive you want to install GRUB
  boot.loader.grub.device = "/dev/sda";

  # boot/kernel stuff
  boot.initrd.availableKernelModules = [
    "ahci"
    "ohci_pci"
    "ehci_pci"
    "pata_atiixp"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sr_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  i18n = {
    consoleKeyMap = "de";
    defaultLocale = "de_DE.UTF-8";
  };

  services.xserver = {
    layout = "de,de";
    xkbVariant = ",neo";
    xkbOptions = "grp:ctrl_shift_toggle,terminate:ctrl_alt_bksp";
    # videoDrivers = [ "mesa" ]; # TODO

    # displayManager.lightdm.enable = true;
    desktopManager.gnome3.enable = true;
  };

  # TODO
  # services.printing = {
  #   enable = true;
  #   drivers = [ pkgs.gutenprint ];
  # };

  # TODO
  # services.openssh.enable = true;

  # “A list of files containing trusted root certificates in PEM format. These
  # are concatenated to form /etc/ssl/certs/ca-certificates.crt”
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];

  # “This option defines the maximum number of jobs that Nix will try to build
  # in parallel. The default is 1. You should generally set it to the total
  # number of logical cores in your system (e.g., 16 for two CPUs with 4 cores
  # each and hyper-threading).”
  nix.maxJobs = 2;

  environment.systemPackages =
    with (import ../packages.nix pkgs);
      system ++
      applications.main ++
      commandline.main;
}
