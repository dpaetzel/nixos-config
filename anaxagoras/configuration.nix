{ pkgs, lib, inputs, ... }:


{
  networking.hostName = "anaxagoras";


  users.extraUsers.david = {
    shell = "${pkgs.fish}/bin/fish";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      # "docker"
      # "lxd"
      "networkmanager"
      "plugdev"
      # "vboxusers"
      # "video" # to be able to use `light`
      "wheel"
    ];
  };


  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/befdf9b2-9ba8-45ce-a0e6-5d25e03dcaaf";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/201fcb80-0361-409f-a878-87719366a4f3"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;


  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  # boot.loader.grub.useOSProber = true;


  hardware.keyboard.zsa.enable = true;


  services.openssh.enable = true;


  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint pkgs.postscript-lexmark ];
  };


  # udev rule for my android phone(s)
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="054c", MODE="0666"
  '';


  # “A list of files containing trusted root certificates in PEM format. These
  # are concatenated to form /etc/ssl/certs/ca-certificates.crt”
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];


  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "22.05";


  # “This option defines the maximum number of jobs that Nix will try to build
  # in parallel. The default is 1. You should generally set it to the total
  # number of logical cores in your system (e.g., 16 for two CPUs with 4 cores
  # each and hyper-threading).”
  nix.maxJobs = lib.mkDefault 4;


  # “Sandboxing is not enabled by default in Nix due to a small performance hit
  # on each build. In pull requests for nixpkgs people are asked to test builds
  # with sandboxing enabled (see Tested using sandboxing in the pull request
  # template) because in https://nixos.org/hydra/ sandboxing is also used.”
  nix.useSandbox = true;
}
