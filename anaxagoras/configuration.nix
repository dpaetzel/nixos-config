{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../common.nix
      ../themeddesktop.nix
      ../workstation.nix
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
      device = "/dev/LinuxData/Home";
      preLVM = false;
    }
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/NixOSRoot";
      fsType = "ext4";
      options = [ "discard" ];
    };

  fileSystems."/home" =
    # { device = "/dev/disk/by-uuid/69465e01-04a9-4d43-8a0b-eb980ea23c86";
    { device = "/dev/mapper/DecryptedHome";
      fsType = "ext4";
    };

  fileSystems."/nix/store" =
    { device = "/dev/LinuxData/NixStore";
      fsType = "ext4";
    };

  swapDevices =
    # [ { device = "/dev/disk/by-uuid/e78ecb48-f1d0-49e9-9ab8-d0fcad961085"; }
    [ { device = "/dev/disk/by-label/Linux\x20Swap"; }
    ];

  # use the systemd efi boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "fbcon=rotate:3" ]; # rotate console by 90 degrees
  boot.extraModulePackages = [ ];

  services.xserver.videoDrivers = lib.mkForce [ "nouveau" ];
    # not working properly (everything gets too big, setting dpi manually doesn't help a thing)
    # videoDrivers = [ "nvidia" ];
    # config = import ./monitors-nouveau.nix;
    # videoDrivers = mkForce [ "nouveau" ];
    # displayManager.sessionCommands =
    #   ''
    #     sleep 1
    #     xrandr --output DP-1 --off --output DVI-I-1 --mode 1280x1024 --pos 0x400 --rotate left --output DVI-D-1 --mode 1680x1050 --pos 2944x0 --rotate right --output HDMI-1 --mode 1920x1080 --pos 1024x400 --rotate normal --primary
    #   '';
  # };

  # other services
  services.openssh.enable = true;
  services.tlp.enable = true; # power management/saving for laptops
  # “A list of files containing trusted root certificates in PEM format. These
  # are concatenated to form /etc/ssl/certs/ca-certificates.crt”
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];

  # “This option defines the maximum number of jobs that Nix will try to build
  # in parallel. The default is 1. You should generally set it to the total
  # number of logical cores in your system (e.g., 16 for two CPUs with 4 cores
  # each and hyper-threading).”
  nix.maxJobs = 8;

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
    drivers = [ pkgs.gutenprint ];
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
          inherit scheme-full; # wrapfig capt-of biblatex biblatex-ieee logreq xstring newtx;
        })
      ]);
}
