{ self, config, pkgs, stdenv, lib, ... }:

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

  # Installed fonts.
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
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
      (nerdfonts.override { fonts = ["FiraCode"]; })
      powerline-fonts
      source-code-pro
      # symbola # Cannot download 2022-06-22
      # terminus_font
      ubuntu_font_family
      unifont
    ];
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
  };

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

  # Proper backlight management.
  programs.light.enable = true;

  # Screen locking.
  programs.slock.enable = true;

  programs.zsh.enable = true;
  programs.fish.enable = true;

  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  # Must be disabled for GnuPGAgent to work (or so someone said once).
  programs.ssh.startAgent = false;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  services.redshift.enable = true;
  location.latitude = 48.3;
  location.longitude = 10.9;
  services.redshift.temperature.day = 5500;
  services.redshift.temperature.night = 2800;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod.ibus.engines = with pkgs.ibus-engines; [ uniemoji ];
    inputMethod.enabled = "ibus";
  };
  console = {
    font = "lat9w-16";
    keyMap = "neo";
  };
  time.timeZone = "Europe/Berlin";
}
