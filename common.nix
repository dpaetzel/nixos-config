{ config, pkgs, ... }:

{
  imports =
  [
    ./packages.nix
  ]

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

  # „On 64-bit systems, whether to support Direct Rendering for 32-bit
  # applications (such as Wine). This is currently only supported for the nvidia
  # and ati_unfree drivers, as well as Mesa.“
  hardware.opengl.driSupport32Bit = true;

  # Networking.
  networking = {
    networkmanager.enable = true;
    networkmanager.basePackages =
      with pkgs; {
        # needed for university vpn
        networkmanager_openconnect =
          pkgs.networkmanager_openconnect.override { openconnect = pkgs.openconnect_gnutls; };
        inherit networkmanager modemmanager wpa_supplicant
                networkmanager_openvpn networkmanager_vpnc
                networkmanager_pptp networkmanager_l2tp;
    };
    extraHosts = ''
      192.168.2.100 anaxagoras
      192.168.2.101 heraklit
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
    defaultLocale = "en_US.UTF-8";
  };
  time.timeZone = "Europe/Berlin";
}
