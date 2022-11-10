{ pkgs, lib, inputs, ... }:


{
  networking.hostName = "sokrates";


  users.extraUsers.david = {
    shell = "${pkgs.fish}/bin/fish";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "docker"
      "lxd"
      "networkmanager"
      "plugdev"
      "vboxusers"
      "video" # to be able to use `light`
      "wheel"
    ];
  };


  fileSystems."/" =
    { device = "/dev/vg/root";
      fsType = "ext4";
    };


  fileSystems."/home" =
    { device = "/dev/vg/home";
      fsType = "ext4";
    };


  swapDevices = [ ];


  # use the GRUB 2 boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


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


  # other services
  hardware.bluetooth.enable = true;


  hardware.keyboard.zsa.enable = true;


  # This is broken somehow as of 2022-05-31 (I always get an index too large
  # error when doing arbtt-stats on the file this creates).
  # services.arbtt = {
  #   enable = true;
  #   sampleRate = 30;
  # };


  services.cron = {
    enable = true;
    systemCronJobs = [
      "* * * * 5 root fstrim /"
      "*/5 7-16 * * * david /home/david/Bin/sync-mail"
      "*/30 * * * * david ${pkgs.vdirsyncer}/bin/vdirsyncer sync 2>&1 /dev/null"
    ];
  };


  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };


  services.openssh.enable = true;


  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint pkgs.postscript-lexmark ];
  };


  services.tlp.enable = true; # power management/saving for laptops


  # udev rule for my android phone(s)
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="054c", MODE="0666"
  '';


  # “A list of files containing trusted root certificates in PEM format. These
  # are concatenated to form /etc/ssl/certs/ca-certificates.crt”
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];


  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";

  nix.settings = {
    # “This option defines the maximum number of jobs that Nix will try to build
    # in parallel. The default is 1. You should generally set it to the total
    # number of logical cores in your system (e.g., 16 for two CPUs with 4 cores
    # each and hyper-threading).”
    max-jobs = lib.mkDefault 4;


    # “Sandboxing is not enabled by default in Nix due to a small performance hit
    # on each build. In pull requests for nixpkgs people are asked to test builds
    # with sandboxing enabled (see Tested using sandboxing in the pull request
    # template) because in https://nixos.org/hydra/ sandboxing is also used.”
    sandbox = true;
  };


  # It's a different problem but in
  # https://github.com/NixOS/nixpkgs/issues/36172, something similar got fixed
  # by using a newer kernel so we try that.
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
