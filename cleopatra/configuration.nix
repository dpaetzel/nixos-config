{ config, pkgs, lib, ... }:

{
  imports =
    [ # include the results of the hardware scan
      # ./hardware-configuration.nix
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ../common.nix
      ../desktop.nix
    ];

  networking.hostName = "cleopatra";

  users.extraUsers.regine = {
    shell = "${pkgs.zsh}/bin/zsh";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d0fc612f-9a80-4e7b-ba4a-2b828f3f5acc";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/sda9";
      fsType = "ext4";
    };

  # fileSystems."/boot" =
  #   { device = "/dev/disk/by-uuid/2A5D-3D0A";
  #     fsType = "vfat";
  #   };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/1053fd58-c824-41a4-ba17-b26e598a11b7"; }
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # TODO is this needed: define on which hard drive you want to install GRUB?
  # boot.loader.grub.device = "/dev/???";

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  services.xserver = {
    layout = "de,de";
    xkbVariant = ",neo";
    xkbOptions = "grp:ctrl_shift_toggle,terminate:ctrl_alt_bksp";
    synaptics = {
      enable = true;
      minSpeed = "0.6";
      maxSpeed = "1.5";
      accelFactor = "0.015";
      twoFingerScroll = true;
      vertEdgeScroll = false;
      palmDetect = true;
    };
    videoDrivers = [ "intel" ];

    # displayManager.lightdm.autoLogin.user = lib.mkForce "regine";
    # TODO windowManager.default = lib.mkForce "gnome";
    # windowManager.xmonad.enable = lib.mkForce false;
    # desktopManager.gnome3.enable = true;
    desktopManager.xfce.enable = true;
  };

  # breaks things
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
    HandleSuspendKey=ignore
    HandleHibernateKey=ignore
    HandleLidSwitch=ignore
    HandleLidSwitchDocked=ignore
  '';

  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  # disable the internal wifi-card as it interfers with the USB one
  # networking.networkmanager.unmanaged = [ "mac:40:f0:2f:57:6b:47" ];

  # nixpkgs.config.chromium.gnomeSupport = true;

  nix.maxJobs = 4;

  environment.systemPackages =
    with (import ../packages.nix pkgs);
      system ++
      applications.main ++
      commandline.main;
}
