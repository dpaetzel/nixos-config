{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:

{
  networking.hostName = "anaxagoras";

  # NVidia GeForce GTX 760 TI OEM
  # Linux x64 (AMD64/EM64T) Display Driver
  # Version: 	470.161.03
  # Release Date: 	2022.11.22
  # Operating System: 	Linux 64-bit
  # Language: 	English (US)
  # File Size: 	259.78 MB
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

  users.extraUsers.david = {
    shell = "${pkgs.fish}/bin/fish";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "audio"
      "cdrom"
      "jackaudio"
      "networkmanager"
      "plugdev"
      "wheel"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/befdf9b2-9ba8-45ce-a0e6-5d25e03dcaaf";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/vg1/home";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/201fcb80-0361-409f-a878-87719366a4f3"; } ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  # os-prober takes *very* long due to an empty drive I have currently
  # installed.
  # boot.loader.grub.useOSProber = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    # Not sure whether the next two are really required if I don't encrypt root
    # but just /home.
    "aesni_intel"
    "cryptd"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  # Decrypt /dev/sda1 (the HDD that /home is on) during boot. Within the LUKS,
  # there is an LVM. This line makes this inner LVM volume available as
  # /dev/mapper/home-decrypted.
  boot.initrd.luks.devices.home-decrypted.device = "/dev/disk/by-uuid/843950ed-e5ca-4604-9398-d840bd84ff81";
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Enabled in initial generated config.
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  # I'm a big noob and can't get jack to work with ardour somehow.
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
    pulse.enable = true;
  };
  hardware.pulseaudio.enable = lib.mkForce false;
  # Acc. to NixOS wiki, rtkit is optional but recommended for using PipeWire.
  security.rtkit.enable = true;

  # anaxagoras has a dongle now! But it does not like Pipewire/Jack. :(
  # hardware.bluetooth.enable = true;

  services.openssh.enable = true;

  services.printing = {
    enable = true;
    drivers = [
      pkgs.gutenprint
      pkgs.hplip
      pkgs.postscript-lexmark
    ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "22.05";

  # “This option defines the maximum number of jobs that Nix will try to build
  # in parallel. The default is 1. You should generally set it to the total
  # number of logical cores in your system (e.g., 16 for two CPUs with 4 cores
  # each and hyper-threading).”
  nix.settings.max-jobs = lib.mkDefault 8;

  # “Sandboxing is not enabled by default in Nix due to a small performance hit
  # on each build. In pull requests for nixpkgs people are asked to test builds
  # with sandboxing enabled (see Tested using sandboxing in the pull request
  # template) because in https://nixos.org/hydra/ sandboxing is also used.”
  nix.settings.sandbox = true;
}
