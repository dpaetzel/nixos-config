{ config, pkgs, ... }:

{
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

  # “Turn on this option if you want to enable all the firmware shipped in
  # linux-firmware.”
  hardware.enableAllFirmware = true;

  # „On 64-bit systems, whether to support Direct Rendering for 32-bit
  # applications (such as Wine). This is currently only supported for the nvidia
  # and ati_unfree drivers, as well as Mesa.“
  hardware.opengl.driSupport32Bit = true;

  # Networking.
  networking = {
    networkmanager.enable = true;
    extraHosts = ''
      192.168.2.100 anaxagoras
      192.168.2.101 heraklit
      192.168.2.102 sokrates
      192.168.2.110 filius
    '';
    firewall.enable = false;
  };

  # Installed fonts.
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      cm_unicode
      corefonts
      dejavu_fonts
      fira
      fira-code
      fira-mono
      inconsolata
      # ipafont
      kochi-substitute
      libertine
      lmmath
      lmodern
      source-code-pro
      symbola
      terminus_font
      ubuntu_font_family
      unifont
      vistafonts
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;

    chromium.pulseSupport = true;
    # chromium = {
    #   enablePepperFlash = true;
    #   enablePepperPDF = true;
    # };
  };

  # TODO fix GTK theming
  # environment.shellInit = ''
    # Set GTK_PATH so that GTK+ can find the Xfce theme engine.
    # export GTK_PATH=${config.system.path}/lib/gtk-2.0

    # Set GTK_DATA_PREFIX so that GTK+ can find the Xfce themes.
    # export GTK_DATA_PREFIX=${config.system.path}

    # export GTK2_RC_FILES=$GTK2_RC_FILES:~/.nix-profile/share/themes/oxygen-gtk/gtk-2.0/gtkrc
  # '';

  environment.variables = {
    BROWSER = "chromium";

    # Prevent DBUS.Error.ServiceUnknown: org.a11y.Bus not provided.
    # https://github.com/NixOS/nixpkgs/issues/16327
    NO_AT_BRIDGE = "1";

    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";

    # Prevent Wine from changing filetype associations.
    # https://wiki.winehq.org/FAQ#How_can_I_prevent_Wine_from_changing_the_filetype_associations_on_my_system_or_adding_unwanted_menu_entries.2Fdesktop_links.3F
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";
  };

  # Proper backlight management.
  programs.light.enable = true;

  programs.zsh.enable = true;
  programs.fish.enable = true;

  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    displayManager.slim = {
      defaultUser = "david";
      enable = true;
      theme = pkgs.fetchurl {
        url = "https://github.com/edwtjo/nixos-black-theme/archive/v1.0.tar.gz";
        sha256 = "13bm7k3p6k7yq47nba08bn48cfv536k4ipnwwp1q1l2ydlp85r9d";
      };
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages : [ haskellPackages.split ];
    };

    # otherwise an xterm spawns the window manager(?!?)
    desktopManager.xterm.enable = false;
  };

  services.redshift.enable = true;
  services.redshift.latitude = "48.3";
  services.redshift.longitude = "10.9";
  services.redshift.temperature.day = 5500;
  services.redshift.temperature.night = 2800;

  virtualisation.docker.enable = true;

  # must be disabled for GnuPGAgent to work (or so someone said)
  programs.ssh.startAgent = false;

  i18n = {
    consoleFont = "lat9w-16";
  };
  time.timeZone = "Europe/Berlin";
}
