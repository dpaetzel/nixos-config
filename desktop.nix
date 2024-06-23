{ ... }:

{
  services.xserver = {
    enable = true;
    xkb.layout = "de";
    xkb.variant = "neo";

    displayManager.lightdm.enable = true;

    desktopManager.xterm.enable = false;

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [ haskellPackages.split ];
    };
  };

  services.picom = {
    enable = true;
    # 2021-08-09 Solves screen tearing in Chrome for me.
    # https://www.reddit.com/r/archlinux/comments/j58isj/i3gaps_picom_screen_tearing_issue/
    backend = "glx";
    fade = true;
    inactiveOpacity = 0.7;
    opacityRules = [
      "100:class_g = 'dmenu'"
      # Not working.
      # "100:class_g = 'gimp'"
      # "100:class_i = 'gimp'"
      # "100:class_g = 'Gimp'"
      # "100:class_i = 'Gimp'"
    ];
    vSync = true;
    settings = {
      "detect-transient" = true;
      "detect-client-leader" = true;
      "focus-exclude" = [ "class_g = 'Gimp'" ];
    };
  };
}
