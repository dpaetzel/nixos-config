{ config, pkgs, ... }:

{
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

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
      192.168.2.102 cleopatra
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
      inconsolata
      # ipafont
      kochi-substitute
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

    # this is a bad browser since pentadactyl's death
    # firefox = {
    #   enableGoogleTalkPlugin = true;
    #   enableAdobeFlash = true;
    # };

    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };
  };

  # TODO fix GTK theming
  # environment.shellInit = ''
    # Set GTK_PATH so that GTK+ can find the Xfce theme engine.
    # export GTK_PATH=${config.system.path}/lib/gtk-2.0

    # Set GTK_DATA_PREFIX so that GTK+ can find the Xfce themes.
    # export GTK_DATA_PREFIX=${config.system.path}

    # export GTK2_RC_FILES=$GTK2_RC_FILES:~/.nix-profile/share/themes/oxygen-gtk/gtk-2.0/gtkrc
  # '';

  # proper backlight management
  programs.light.enable = true;

  programs.zsh.enable = true;
  programs.fish.enable = true;

  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
  };

  # must be disabled for GnuPGAgent to work
  programs.ssh.startAgent = false;

  i18n = {
    consoleFont = "lat9w-16";
  };
  time.timeZone = "Europe/Berlin";
}
