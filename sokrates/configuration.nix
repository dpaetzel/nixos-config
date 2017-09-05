{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../common.nix
    ];

  networking.hostName = "sokrates";

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
  # boot.initrd.luks.devices = [
  #   { name = "crypted";
  #     device = "/dev/sda3";
  #     preLVM = true;
  #   }
  # ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-label/home";
      fsType = "ext4";
    };

  # fileSystems."/boot" =
  #   { device = "/dev/disk/by-uuid/C0B8-6B10";
  #     fsType = "vfat";
  #   };

  swapDevices = [ ];

  # use the GRUB 2 boot loader
  boot.loader.systemd-boot.enable = true;
  # define on which hard drive you want to install GRUB
  boot.loader.grub.device = "/dev/nvme0n1";
  # TODO is this needed (was generated…)?
  # boot.loader.efi.canTouchEfiVariables = true;

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

  i18n = {
    consoleKeyMap = "neo";
    defaultLocale = "en_US.UTF-8";
  };

  services.xserver = {
    layout = "de";
    xkbVariant = "neo";
    # synaptics = {
    #   enable = true;
    #   # 1 should be left, 2 should be right and 3 should be middle click
    #   additionalOptions = ''
    #     Option "TapButton1" "1"
    #     Option "TapButton2" "3"
    #     Option "TapButton3" "2"
    #   '';
    # };
    videoDrivers = [ "intel" ];

    displayManager.slim = {
      defaultUser = "david";
      enable = true;
      theme = pkgs.fetchurl {
        url = "https://github.com/edwtjo/nixos-black-theme/archive/v1.0.tar.gz";
        sha256 = "13bm7k3p6k7yq47nba08bn48cfv536k4ipnwwp1q1l2ydlp85r9d";
      };
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages : [ haskellPackages.split ];
    };
    # otherwise an xterm spawns the window manager(?!?)
    desktopManager.xterm.enable = false;
  };

  # seems to make stuff like Chromium go slightly bananas in terms of performance
  # hardware.opengl.extraPackages = with pkgs; [
  #   vaapiIntel libvdpau-va-gl vaapiVdpau
  # ];

  # other services
  services.openssh.enable = true;
  services.tlp.enable = true; # power management/saving for laptops
  services.cron.enable = true;
  # udev rule for my android phone(s)
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="054c", MODE="0666"
  '';

  services.cron.systemCronJobs = [
    "0 2 * * * root fstrim /"
  ];

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
              networkmanager_pptp networkmanager_l2tp;
  };
  # networking.wireless.enable = true;  # wireless support via wpa_supplicant

  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint pkgs.postscript-lexmark ];
  };

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
        (with texlive; combine {
          # inherit scheme-medium minted units collection-bibtexextra ifplatform xstring doublestroke csquotes;
          # inherit xstring doublestroke csquotes;
          inherit scheme-full wrapfig capt-of biblatex biblatex-ieee logreq xstring newtx;
          # ieeetran?
        })
        biber

        powertop

        wine winetricks # always handy to keep around; you never know x)

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
