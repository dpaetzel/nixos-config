# home-manager configuration file of `anaxagoras` (replaces ~/.config/nixpkgs/home.nix).
{
  pkgs,
  config,
  configPath,
  ...
}:
{
  # Don't change this. Version that I originally installed home-manager with.
  #
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";

  # Required so that I can configure GUI stuff like polybar via home-manager.
  xsession.enable = true;

  programs.ssh = {
    enable = true;
    extraConfig = ''
      PreferredAuthentications publickey
      IdentityFile /home/%u/.ssh/id_rsa.%h.%r
    '';
    matchBlocks = {
      "oc*.informatik.uni-augsburg.de" = {
        hostname = "%h";
        identityFile = "/home/%u/.ssh/id_rsa.oc.%r";
      };
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCodeNerdFontComplete-Retina";
      size = 12;
    };
    extraConfig = ''
      disable_ligatures cursor

      # NOTE Have to disable ligatures here, otherwise fi becomes a telephone (and
      # other problems).
      # https://github.com/MonoLisaFont/feedback/issues/15#issuecomment-660287748
      # font_features none
      # font_features InconsolataNerdFontCompleteM-Regular -liga +calt
      # ss04 dollar
      font_features FiraCodeNerdFontComplete-Retina +zero +ss04

      cursor_shape block
      cursor_blink_interval 0

      scrollback_lines 10000

      enable_audio_bell no

      confirm_os_window_close 0

      update_check_interval 0

      background            #000000
      foreground            #ffffff
      cursor                #ffffff
      selection_background  #b4d5ff
      color0                #000000
      color8                #545753
      color1                #cc0000
      color9                #ef2828
      color2                #4e9a05
      color10               #8ae234
      color3                #c4a000
      color11               #fce94e
      color4                #3464a4
      color12               #719ecf
      color5                #74507a
      color13               #ad7ea7
      color6                #05989a
      color14               #34e2e2
      color7                #d3d7cf
      color15               #ededec
      selection_foreground #000000
    '';
    keybindings = {
      "ctrl+shift+o" = "launch --stdin-source=@last_cmd_output --type=clipboard";
      "ctrl+h" = "launch --cwd=current --type=os-window";
    };
  };

  programs.firefox = {
    enable = true;
    # TODO Add nativeMessagingHosts for tridactyl
    # TODO Add config options
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  services.polybar = {
    enable = true;
    script = ''
      polybar top &
      polybar bottom &
    '';
    settings = import ./polybar.nix;
  };

  # Instead of getting
  # ```
  # DBI connect(…) failed: unable to open database file at
  # /run/current-system/sw/bin/command-not-found line 13.
  # cannot open database `…' at /run/current-system/sw/bin/command-not-found
  # line 13.
  # ```
  # I want to get
  # ```
  # The program 'hello' is currently not installed. It is provided by several
  # packages. You can install it by typing one of the following:
  # nix-env -iA nixpkgs.haskellPackages.hello.out
  # nix-env -iA nixpkgs.mbedtls.out
  # nix-env -iA nixpkgs.hello.out
  # …
  # ```
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  # We'll see when this bites us.
  xdg.configFile."MuseScore/HomeManagerInit_MuseScore4.ini" = {
    text = ''
      [application]
      hasCompletedFirstLaunchSetup=true
      paths\myPlugins=/home/david
      paths\myScores=/home/david
      paths\mySoundfonts=/home/david/.config/MuseScore/SoundFonts
      paths\myStyles=/home/david
      paths\myTemplates=/home/david
      skippedVersion=4.4.3

      [cloud]
      clientId=-10ec283abac1cf0c

      [ui]
      application\currentThemeCode=dark
    '';
    # Copy and backup current config so that we can change stuff (and can see
    # what we change in the program itself last time we used it).
    # Inspired by: https://github.com/nix-community/home-manager/issues/3090#issuecomment-2010891733
    #
    # This is still a bit wobbly and I may have to delete some of the files by
    # hand to make it do everything on activation (I think I had to do that
    # right now but I'm not 100% sure).
    onChange = ''
      mv ${config.xdg.configHome}/MuseScore/MuseScore4.ini ${config.xdg.configHome}/MuseScore/MuseScore4.ini.prev || true
      cp ${config.xdg.configHome}/MuseScore/HomeManagerInit_MuseScore4.ini ${config.xdg.configHome}/MuseScore/MuseScore4.ini
      chmod u+w ${config.xdg.configHome}/MuseScore/MuseScore4.ini
    '';
  };
}
