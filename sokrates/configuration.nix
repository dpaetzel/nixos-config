{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./cachix.nix
      ../common.nix
      ../desktop.nix
      ../theme.nix
      ./uni-mounts.nix
      ../workstation.nix
    ];


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


  # fileSystems."/home2" =
  #   { device = "/dev/disk/by-uuid/269e80d9-7625-4d4e-ac63-38b935ff7b68";
  #     fsType = "ext4";
  #     noCheck = true;
  #   };

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


  programs.singularity.enable = true;


  services.arbtt = {
    enable = true;
    sampleRate = 30;
  };


  services.cron = {
    enable = true;
    systemCronJobs = [
      "* * * * 5 root fstrim /"
      "*/5 7-16 * * * david /home/david/Bin/sync-mail"
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


  # “Auto-detect the connect display hardware and load the appropiate X11 setup
  # using xrandr or disper.” – https://github.com/wertarbyte/autorandr
  # TODO These problems need to be solved:
  # - does not respect my dzen/conky setup (needs postswitch-script)
  # - does only work (exactly) every 2nd time when putting the laptop into the docking station
  # services.autorandr.enable = true;


  # “A list of files containing trusted root certificates in PEM format. These
  # are concatenated to form /etc/ssl/certs/ca-certificates.crt”
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];


  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";


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


  # It's a different problem but in
  # https://github.com/NixOS/nixpkgs/issues/36172, something similar got fixed
  # by using a newer kernel so we try that.
  boot.kernelPackages = pkgs.linuxPackages_latest;


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
        netlogo
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
        })
        biber
      ]);
}
