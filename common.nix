{
  self,
  config,
  pkgs,
  stdenv,
  lib,
  pythonEnv,
  inputs,
  ...
}:

{
  # Required for ThinkPad T470 Wifi and Bluetooth drivers.
  hardware.enableRedistributableFirmware = true;

  # „On 64-bit systems, whether to support Direct Rendering for 32-bit
  # applications (such as Wine). This is currently only supported for the nvidia
  # and ati_unfree drivers, as well as Mesa.“
  hardware.graphics.enable32Bit = true;

  # Networking.
  networking = {
    networkmanager.enable = true;
    extraHosts = ''
      192.168.178.100 anaxagoras
      192.168.178.101 heraklit
      192.168.178.102 sokrates
      192.168.178.103 leukipp
      192.168.178.110 filius
    '';
    firewall.enable = false;
  };

  # Manual mount:
  # `sudo mount -t cifs -o uid=1000,gid=100,credentials=/home/david/1Projekte/Cloud/credentials //192.168.178.120/HoefflCloud /mnt/HoefflCloud`
  # See https://wiki.archlinux.org/title/Autofs#Samba .
  services.autofs.autoMaster =
    let
      mapConf = pkgs.writeText "auto" ''
        HoefflCloud -fstype=cifs,uid=1000,gid=100,credentials=/home/david/5Code/nixos-config/credentials ://192.168.178.120/HoefflCloud
      '';
    in
    ''
      /mnt/HoefflCloud file:${mapConf} --timeout 60 --browse
    '';
  services.autofs.enable = true;

  environment.systemPackages =
    with pkgs;
    [
      trash-cli # Put stuff into freedesktop-compatible trash.
    ]
    # Create a script package for all shell scripts in ./scripts.
    ++ (map (fpath: pkgs.callPackage fpath { }) (
      lib.filter (file: lib.hasSuffix ".nix" file) (lib.filesystem.listFilesRecursive ./scripts)
    ));
  # TODO While this avoids repeating `writeShellScriptBin` in each of the
  # script files, this does not allow me to specify script dependencies
  # ++ (map (
  #   fname: writeShellScriptBin (toString fname) (builtins.readFile fname)
  # ) (lib.filesystem.listFilesRecursive ./scripts));

  # Installed fonts.
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      cm_unicode
      corefonts
      dejavu_fonts
      fira
      fira-code
      # fira-code-symbols
      font-awesome
      google-fonts
      inconsolata
      # ipafont
      kochi-substitute
      libertine
      lmmath
      lmodern
      noto-fonts-emoji # seems to be broken as of 2023-02
      noto-fonts-monochrome-emoji
      twitter-color-emoji
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "NerdFontsSymbolsOnly"
        ];
      })
      powerline-fonts
      source-code-pro
      # symbola # Cannot download 2022-06-22
      # terminus_font
      ubuntu_font_family
      unifont
    ];
    fontconfig.defaultFonts = {
      emoji = [ "Twitter Color Emoji" ];
    };
  };

  nix = {
    package = pkgs.nixFlakes;
    # keep-* is recommended for nix-direnv.
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    settings.auto-optimise-store = true;

    # I want `nix run nixpkgs#nixpkgs` to use the commit of this Flake.
    # registry.nixpkgs.flake = nixpkgs;
    # I don't want to use channels b/c Flakes are the way to go.
    channel.enable = false;
  };

  # https://github.com/Saethox/nixos-config/blob/main/nixos/default.nix#L35-L36
  # Add each flake input as a registry to make Nix commands consistent with
  # this flake.
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
    (lib.filterAttrs (_: lib.isType "flake")) inputs
  );

  # https://github.com/Saethox/nixos-config/blob/main/nixos/default.nix#L38
  # Add the inputs to the system's legacy channels, making legacy nix commands
  # consistent as well.
  # https://github.com/NixOS/nix/issues/9574
  nix.nixPath = [ "/etc/nix/path" ];
  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  # TODO Is this still required?
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  environment.variables = {
    BROWSER = "firefox";
    EDITOR = "v";

    # Prevent DBUS.Error.ServiceUnknown: org.a11y.Bus not provided.
    # https://github.com/NixOS/nixpkgs/issues/16327
    # NO_AT_BRIDGE = "1"; # TODO not needed any more?

    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";

    # Prevent Wine from changing filetype associations.
    # https://wiki.winehq.org/FAQ#How_can_I_prevent_Wine_from_changing_the_filetype_associations_on_my_system_or_adding_unwanted_menu_entries.2Fdesktop_links.3F
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";

    # this is set by ibus package already
    # GTK_IM_MODULE = lib.mkForce "ibus";
    # QT_IM_MODULE = lib.mkForce "ibus";
    # XMODIFIERS = lib.mkForce "@im=ibus";

    QT_STYLE_OVERRIDE = "GTK+";

    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "_JAVA_OPTIONS" = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";

    "_selected_drivers" = "ath9k";
  };

  # Screen locking.
  programs.slock.enable = true;

  programs.zsh.enable = true;
  programs.fish.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 86400;
    };
  };
  # Must be disabled for GnuPGAgent to work (or so someone said once).
  programs.ssh.startAgent = false;

  # Sometimes I'm less masochistic and don't want to package stuff but just run
  # it. This allows to Just Execute stuff (i.e. `./thefile`).
  programs.nix-ld.enable = true;
  # Set up the libraries to load with `nix-ld`.
  # programs.nix-ld.libraries = with pkgs; [
  #   stdenv.cc.cc
  #   zlib
  #   fuse3
  #   icu
  #   nss
  #   openssl
  #   curl
  #   expat
  # ];

  # Not the best but also not the worst, I guess.
  programs.thunderbird.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    # I don't know why past-David put this here.
    daemon.config = {
      default-sample-format = "s24";
      default-sample-rate = 48000;
    };
  };
  # udev rule for my android phone(s)
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="054c", MODE="0666"
  '';

  hardware.keyboard.zsa.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  services.clipmenu = {
    enable = true;
    syncPrimaryToClipboard = true;
  };

  # Required for udiskie.
  services.udisks2.enable = true;

  # Please don't lock me out.
  services.earlyoom = {
    enable = true;
    # Minimum available memory and swap in percent above which “the killing
    # begins” (i.e. if both are surpassed at the same time).
    freeMemThreshold = 10;
    freeSwapThreshold = 10;
    # I want to know what's going on.
    enableNotifications = true;
    extraArgs = [ "--prefer '^(emanote|.spotify-wrappe|.mscore-wrapped|Isolated Web Co)$'" ];
  };

  # “A list of files containing trusted root certificates in PEM format. These
  # are concatenated to form /etc/ssl/certs/ca-certificates.crt”
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];

  services.redshift.enable = true;
  location.latitude = 48.3;
  location.longitude = 10.9;
  services.redshift.temperature.day = 5500;
  services.redshift.temperature.night = 2800;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    # inputMethod.ibus.engines = with pkgs.ibus-engines; [ uniemoji ];
    # inputMethod.enabled = "ibus";
  };
  console = {
    font = "lat9w-16";
    keyMap = "neo";
  };
  time.timeZone = "Europe/Berlin";

  dp.fish.enable = true;
  dp.julia.enable = true;
  dp.latex.enable = true;
  dp.emacs.enable = true;
}
