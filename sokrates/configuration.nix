{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../common.nix
      ../desktop.nix
      ../theme.nix
      ../workstation.nix
    ];


  networking.hostName = "sokrates";


  users.extraUsers.david = {
    shell = "${pkgs.fish}/bin/fish";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "docker"
      "networkmanager"
      "video" # to be able to use `light`
      "wheel"
    ];
  };


  fileSystems."/" =
    { device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };


  fileSystems."/home" =
    { device = "/dev/disk/by-label/home";
      fsType = "ext4";
    };


  swapDevices = [ ];


  # use the GRUB 2 boot loader
  boot.loader.systemd-boot.enable = true;
  # TODO is this needed: define on which hard drive you want to install GRUB?
  boot.loader.grub.device = "/dev/nvme0n1";
  # TODO Dominik says that I should do this (b/c using grub.device is the legacy method)
  # boot.loader.grub.device = "nodev";
  # boot.loader.efi.canTouchEfiVariables = true;
  # … etc.


  # boot/kernel stuff
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];


  services.xserver.videoDrivers = lib.mkForce [ "intel" ];


  # other services
  hardware.bluetooth.enable = true;


  services.openssh.enable = true;


  services.tlp.enable = true; # power management/saving for laptops


  # udev rule for my android phone(s)
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="054c", MODE="0666"
  '';


  services.cron = {
    enable = true;
    systemCronJobs = [
      "* * * * 5 root fstrim /"
    ];
  };


  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint pkgs.postscript-lexmark ];
  };


  # “Auto-detect the connect display hardware and load the appropiate X11 setup
  # using xrandr or disper.” – https://github.com/wertarbyte/autorandr
  # TODO These problems need to be solved:
  # - does not respect my dzen/conky setup (needs postswitch-script)
  # - does only work (exactly) every 2nd time when putting the laptop into the docking station
  # services.autorandr.enable = true;


  # “A list of files containing trusted root certificates in PEM format. These
  # are concatenated to form /etc/ssl/certs/ca-certificates.crt”
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];


  # “This option defines the maximum number of jobs that Nix will try to build
  # in parallel. The default is 1. You should generally set it to the total
  # number of logical cores in your system (e.g., 16 for two CPUs with 4 cores
  # each and hyper-threading).”
  nix.maxJobs = lib.mkDefault 4;


  networking.networkmanager.basePackages =
    with pkgs; {
      # needed for university vpn; thanks Profpatsch!
      networkmanager_openconnect =
        pkgs.networkmanager_openconnect.override { openconnect = pkgs.openconnect_gnutls; };
      inherit networkmanager modemmanager wpa_supplicant
              networkmanager_openvpn networkmanager_vpnc
              networkmanager_l2tp;
              # TODO pptp not existing any more
              # networkmanager_pptp
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
        # TODO extract this to texlive.nix
        (with texlive; combine {
          inherit
            biblatex
            biblatex-ieee
            capt-of
            inconsolata
            libertine
            logreq
            newtx
            scheme-full
            wrapfig
            xstring
            ;
          # ieeetran?
        })
        biber

        # other pkgs
        # eclipses.eclipse-sdk-442 # latest classic
        # eclipses.eclipse-sdk-452 # latest mars
        # eclipses.eclipse-sdk-46 # neon
        # jdk

        # sbt
        # scala
        # idea.idea-community

        # nodejs
      ]);
}
