{ config, pkgs, stdenv, ... }:

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
    packageOverrides = super:
      let self = super.pkgs;
      in {
        alsaLib116 = super.alsaLib.overrideAttrs (oldAttrs: rec {
          name = "alsa-lib-1.1.6";
          src = self.fetchurl {
            url = "mirror://alsa/lib/${name}.tar.bz2";
            sha256 = "096pwrnhj36yndldvs2pj4r871zhcgisks0is78f1jkjn9sd4b2z";
          };
        });
        # audacity is broken because of ALSA lib
        audacity221 =
          (super.audacity.override { alsaLib = self.alsaLib116; }).overrideAttrs
          (oldAttrs: rec {
            version = "2.2.1";
            name = "audacity-${version}";
            src = self.fetchurl {
              url =
                "https://github.com/audacity/audacity/archive/Audacity-${version}.tar.gz";
              sha256 = "1n05r8b4rnf9fas0py0is8cm97s3h65dgvqkk040aym5d1x6wd7z";
            };
          });
        # TODO use this in latex distribution, too
        # biberFixed = super.biber.overrideAttrs(oldAttrs: rec {
        #   patches = stdenv.lib.optionals (stdenv.lib.versionAtLeast pkgs.perlPackages.perl.version "5.30") [
        #     (pkgs.fetchpatch {
        #       name = "biber-fix-tests.patch";
        #       url = "https://git.archlinux.org/svntogit/community.git/plain/trunk/biber-fix-tests.patch?h=5d0fffd493550e28b2fb81ad114d62a7c9403812";
        #       sha256 = "1ninf46bxf4hm0p5arqbxqyv8r98xdwab34vvp467q1v23kfbhya";
        #     })

        #     (pkgs.fetchpatch {
        #       name = "biber-fix-tests-2.patch";
        #       url = "https://git.archlinux.org/svntogit/community.git/plain/trunk/biber-fix-tests-2.patch?h=5d0fffd493550e28b2fb81ad114d62a7c9403812";
        #       sha256 = "1l8pk454kkm0szxrv9rv9m2a0llw1jm7ffhgpyg4zfiw246n62x0";
        #     })
        #   ];
        # });
        profiledHaskellPackages = self.haskellPackages.override {
          overrides = self: super: {
            mkDerivation = args:
              super.mkDerivation (args // { enableLibraryProfiling = true; });
          };
        };
        # Disable suspending my Bluetooth headset. Combine two things to do this:
        # – https://nixos.wiki/wiki/PulseAudio#Clicking_and_Garbled_Audio_for_Creative_Sound_Cards
        # – https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting#Bluetooth_headset_replay_problems
        # This does not work because Bluetooth support is disabled that way.
        # hardware.pulseaudio.configFile = pkgs.runCommand "default.pa" {} ''
        #   sed 's/^load-module module-suspend-on-idle/#\0/' \
        #     ${pkgs.pulseaudio}/etc/pulse/default.pa > $out
        # '';
        # I think we need an overlay instead:
        # pulseaudio = self.pulseaudio.overrideAttrs {
        # }
        python36Packages = super.python36Packages.override (oldAttrs: rec {
          # tests fail but libraries work(?)
          overrides = self: super: rec {
            pyflakes = super.pyflakes.overrideAttrs (z: rec {
              doCheck = false;
              doInstallCheck = false;
            });
            whoosh = super.whoosh.overrideAttrs (z: rec {
              doCheck = false;
              doInstallCheck = false;
            });
          };
        });
        # TODO 2020-05-12 p7zip is marked as insecure but I'm not sure whether
        # winetricks really always needs it?
        winetricks = super.winetricks.override (oldAttrs : rec {
          p7zip = "";
        });
      };
  };

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

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  services.redshift.enable = true;
  location.latitude = 48.3;
  location.longitude = 10.9;
  services.redshift.temperature.day = 5500;
  services.redshift.temperature.night = 2800;

  # must be disabled for GnuPGAgent to work (or so someone said)
  programs.ssh.startAgent = false;

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
