{ config, pkgs, ... }:

# TODO https://gist.github.com/taohansen/d15e1fe4674a286cb9bcd8e3378a9f23

# programs.adb.enable = true;
# programs.chromium = {
#   enable = true;
#   extensions = [
#   "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
#   "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
#   "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
#   ];
#  };
# };

{
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
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      cm_unicode
      corefonts
      dejavu_fonts
      fira
      fira-code
      fira-code-symbols
      inconsolata
      # ipafont
      kochi-substitute
      libertine
      lmmath
      lmodern
      nerdfonts
      powerline-fonts
      source-code-pro
      symbola
      terminus_font
      ubuntu_font_family
      unifont
      vistafonts
    ];
  };

  nixpkgs.config = {
    android_sdk.accept_license = true;
    oraclejdk.accept_license = true;
    allowUnfree = true;

    chromium.pulseSupport = true;


    # The variable super refers to the Nixpkgs set before the overrides are
    # applied and self refers to it after the overrides are applied.
    # (https://stackoverflow.com/a/36011540/6936216)
    packageOverrides = super: let self = super.pkgs; in {
      alsaLib116 = super.alsaLib.overrideAttrs(oldAttrs: rec {
        name = "alsa-lib-1.1.6";
        src = self.fetchurl {
          url = "mirror://alsa/lib/${name}.tar.bz2";
          sha256 = "096pwrnhj36yndldvs2pj4r871zhcgisks0is78f1jkjn9sd4b2z";
        };
      });
      # audacity is broken because of ALSA lib
      audacity221 = (super.audacity.override { alsaLib = self.alsaLib116; }).overrideAttrs(oldAttrs: rec {
        version = "2.2.1";
        name = "audacity-${version}";
        src = self.fetchurl {
          url = "https://github.com/audacity/audacity/archive/Audacity-${version}.tar.gz";
          sha256 = "1n05r8b4rnf9fas0py0is8cm97s3h65dgvqkk040aym5d1x6wd7z";
        };
      });
      # dmenu-4.9 is broken
      dmenu48 = super.dmenu.overrideAttrs(oldAttrs: rec {
        name = "dmenu-4.8";
        src = self.fetchurl {
          url = "https://dl.suckless.org/tools/${name}.tar.gz";
          sha256 = "0qfvfrj10xlwd9hkvb57wshryan65bl6423h0qhiw1h76rf5lqgy";
        };
      });
      pass = super.pass.override { dmenu = self.dmenu48; };
      profiledHaskellPackages = self.haskellPackages.override {
        overrides = self: super: {
          mkDerivation = args: super.mkDerivation(args // {
            enableLibraryProfiling = true;
          });
        };
      };
      python36Packages = super.python36Packages.override(oldAttrs: rec {
        # tests fail but libraries work(?)
        overrides = self : super : rec {
          pyflakes = super.pyflakes.overrideAttrs(z: rec {
            doCheck = false;
            doInstallCheck = false;
          });
          whoosh = super.whoosh.overrideAttrs(z: rec {
            doCheck = false;
            doInstallCheck = false;
          });
        };
      });
      vdirsyncer = super.vdirsyncer.overrideAttrs(oldAttrs: rec {
        patches = oldAttrs.patches ++
          [(self.fetchpatch {
            url = https://github.com/pimutils/vdirsyncer/pull/788.patch;
            sha256 = "0vl942ii5iad47y63v0ngmhfp37n30nxyk4j7h64b95fk38vfwx9";
          })];
        }
      );
    };
  };

  environment.variables = {
    BROWSER = "firefox";
    EDITOR = "emacsclient -c -a emacs";

    # Prevent DBUS.Error.ServiceUnknown: org.a11y.Bus not provided.
    # https://github.com/NixOS/nixpkgs/issues/16327
    # NO_AT_BRIDGE = "1"; # TODO not needed any more?

    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";

    # Prevent Wine from changing filetype associations.
    # https://wiki.winehq.org/FAQ#How_can_I_prevent_Wine_from_changing_the_filetype_associations_on_my_system_or_adding_unwanted_menu_entries.2Fdesktop_links.3F
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";

    # don't know why this was here, but it got overriden by my ibus/uniemoji
    # setup anyway
    # GTK_IM_MODULE = "xim";
    # QT_IM_MODULE = "xim";

    QT_STYLE_OVERRIDE = "GTK+";

    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "_JAVA_OPTIONS" = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";

    "_selected_drivers" = "ath9k";
  };

  # Proper backlight management.
  programs.light.enable = true;

  programs.zsh.enable = true;
  programs.fish.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  services.redshift.enable = true;
  services.redshift.latitude = "48.3";
  services.redshift.longitude = "10.9";
  services.redshift.temperature.day = 5500;
  services.redshift.temperature.night = 2800;

  # must be disabled for GnuPGAgent to work (or so someone said)
  programs.ssh.startAgent = false;

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "neo";
    defaultLocale = "en_US.UTF-8";
    inputMethod.ibus.engines = with pkgs.ibus-engines; [ uniemoji ];
    inputMethod.enabled = "ibus";
  };
  time.timeZone = "Europe/Berlin";
}
