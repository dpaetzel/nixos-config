{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../common.nix
      ../media.nix
    ];

  networking.hostName = "heraklit";

  users.extraUsers.media = {
    shell = "${pkgs.zsh}/bin/zsh";
    isNormalUser = true;
    uid = 1001;
    extraGroups = [
      "networkmanager"
    ];
  };

  users.extraUsers.david = {
    shell = "${pkgs.zsh}/bin/zsh";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4f351262-a1cd-443c-a14d-37aca4336eb1";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/f34b28fa-6ebd-4b8e-9261-4ac6fc85c19e";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/ff4fa9fc-adc1-48a4-b21f-ff418ab338d8"; }
    ];

  # use the GRUB 2 boot loader
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # define on which hard drive you want to install GRUB
  boot.loader.grub.device = "/dev/sda";

  # boot/kernel stuff
  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "sdhci_pci"
    "rtsx_pci_sdmmc"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "video=LVDS-1:d" ];

  services.xserver.videoDrivers = lib.mkForce [ "intel" ];

  # other services
  services.openssh.enable = true;
  services.tlp.enable = true; # power management/saving for laptops
  services.cron.enable = true;

  # “A list of files containing trusted root certificates in PEM format. These
  # are concatenated to form /etc/ssl/certs/ca-certificates.crt”
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];

  # “This option defines the maximum number of jobs that Nix will try to build
  # in parallel. The default is 1. You should generally set it to the total
  # number of logical cores in your system (e.g., 16 for two CPUs with 4 cores
  # each and hyper-threading).”
  nix.maxJobs = 4;

  # nixpkgs.config = {
  #   kodi = {
  #     enableAdvancedLauncher = true;
  #   };
  # };

  environment.systemPackages =
    with (import ../packages.nix pkgs);
      system ++
      commandline.main ++
      [
        pkgs.pavucontrol
        pkgs.vim
        pkgs.google-chrome
        # kodi
        # pkgs.kodiPlugins.advanced-launcher
        pkgs.matchbox
        pkgs.jwm
      ] ++
      [
        pkgs.wineStable
        pkgs.winetricks
      ];
}
