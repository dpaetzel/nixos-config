{ pkgs, lib, inputs, ... }:


{
  networking.hostName = "sokrates";


  users.extraUsers.david = {
    shell = "${pkgs.fish}/bin/fish";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "docker"
      "libvirtd"
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


  swapDevices = [{device = "/dev/vg/swap";}];


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


  programs.firefox = {
    enable = true;
    # TODO Retry getting this to work using “please add `tridactyl-native` to
    # `programs.firefox.nativeMessagingHosts.packages` instead”.
    # This doesn't seem to work out of the box?
    # nativeMessagingHosts.tridactyl = true;
    # package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    #   # https://github.com/openlab-aux/vuizvui/blob/fc26d6ac90386bb8b5630fee569db17e7cffa882/pkgs/aszlig/firefox/default.nix#L43
    #   extraNativeMessagingHosts = [
    #     (lib.writeTextFile {
    #       name = "tridactyl-native";
    #       destination = "/lib/mozilla/native-messaging-hosts/tridactyl.json";
    #       text = builtins.toJSON {
    #         name = "tridactyl";
    #         description = "Tridactyl native command handler";
    #         path = "${pkgs.tridactyl-native}/bin/native_main";
    #         type = "stdio";
    #         # allowed_extensions = [ extensions.tridactyl-vim.extid ];
    #         allowed_extensions = [ ];
    #       };
    #     })
    #   ];
    # };
    # TODO nativeMessagingHosts.passff.enable = true;
  };


  programs.starship.enable = true;

  # TODO starship, eza have more options if i use home-manager


  # This is broken somehow as of 2022-05-31 (I always get an index too large
  # error when doing arbtt-stats on the file this creates).
  # services.arbtt = {
  #   enable = true;
  #   sampleRate = 30;
  # };


  # For Gnome calendar to work.
  #
  # See https://nixos.wiki/wiki/GNOME/Calendar .
  # programs.dconf.enable = true;
  # services.gnome.evolution-data-server.enable = true;
  # services.gnome.gnome-online-accounts.enable = true;
  # services.gnome.gnome-keyring.enable = true;


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


  services.mysql = {
    enable = true;
    package = pkgs.mysql;
    ensureDatabases = [ "mlflow_db" ];
    ensureUsers = [{
      name = "mlflow";
      ensurePermissions = { "mlflow_db.*" = "ALL PRIVILEGES"; };
    }];
  };


  services.openssh.enable = true;


  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint pkgs.hplip pkgs.postscript-lexmark ];
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


    # “A list of names of users that have additional rights when connecting to the
    # Nix daemon, such as the ability to specify additional binary caches, or to
    # import unsigned NARs.” The default only contains `"root"` but I may want
    # to use devenvs with custom caches.
    trusted-users = [ "root" "david" ];
  };


  # It's a different problem but in
  # https://github.com/NixOS/nixpkgs/issues/36172, something similar got fixed
  # by using a newer kernel so we try that.
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
