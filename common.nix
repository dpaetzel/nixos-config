{ self, config, pkgs, stdenv, lib, pythonEnv, inputs, ... }:

{
  # Required for ThinkPad T470 Wifi and Bluetooth drivers.
  hardware.enableRedistributableFirmware = true;

  # „On 64-bit systems, whether to support Direct Rendering for 32-bit
  # applications (such as Wine). This is currently only supported for the nvidia
  # and ati_unfree drivers, as well as Mesa.“
  hardware.opengl.driSupport32Bit = true;

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

  environment.systemPackages = with pkgs;
    [
      trash-cli # Put stuff into freedesktop-compatible trash.
    ]
    # Create a script package for all shell scripts in ./scripts.
    ++ (map (fpath: pkgs.callPackage fpath {}) (lib.filesystem.listFilesRecursive ./scripts));
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
      # fira-code
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
      (nerdfonts.override { fonts = ["FiraCode"]; })
      powerline-fonts
      source-code-pro
      # symbola # Cannot download 2022-06-22
      # terminus_font
      ubuntu_font_family
      unifont
    ];
    fontconfig.defaultFonts = {
      emoji = ["Twitter Color Emoji"];
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
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # https://github.com/Saethox/nixos-config/blob/main/nixos/default.nix#L38
  # Add the inputs to the system's legacy channels, making legacy nix commands
  # consistent as well.
  # https://github.com/NixOS/nix/issues/9574
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

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
  programs.fish = {
    enable = true;
    shellAliases = {
      p = "${pythonEnv}/bin/ipython --profile=p";
      pplot="${pythonEnv}/bin/ipython --profile=p --matplotlib=auto";
      # Local shell in case I changed something but did not push yet.
      pl="nix run path:/home/david/NixOS#pythonShell -- --profile=p";
      # No profile.
      pn = "${pythonEnv}/bin/ipython";
      mvt = "trash-put --verbose";
      # Unclear why this is not part of the `trash-*` utilities.
      trash-size = "du -hs ~/.local/share/Trash";
      rm = "echo Use `mvt` or `command rm`";
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 86400;
    };
  };
  # Must be disabled for GnuPGAgent to work (or so someone said once).
  programs.ssh.startAgent = false;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    # I don't know why past-David put this here.
    daemon.config = {
      default-sample-format = "s24";
      default-sample-rate = 48000;
    };
  };

  services.emacs = {
    enable = true;
    defaultEditor = true;
    # Emacs is central to everything, so let's pin its version to more
    # consciously upgrade it.
    package = pkgs.myemacs;
  };

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
}
