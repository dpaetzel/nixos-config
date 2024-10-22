# home-manager configuration file of `anaxagoras` (replaces ~/.config/nixpkgs/home.nix).
{ pkgs, ... }:
{
  # Don't change this. Version that I originally installed home-manager with.
  #
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";

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
}
