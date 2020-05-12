{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "neo";

    # TODO only laptops need this
    libinput = {
      enable = true;
      disableWhileTyping = true;
      scrollMethod = "twofinger";
    };

    displayManager.lightdm.enable = true;

    # desktopManager.default = "custom";
    desktopManager.xterm.enable = false;

    windowManager.default = "xmonad";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [ haskellPackages.split ];
    };
  };

  services.compton = {
    enable = true;
    fade = true;
    inactiveOpacity = 0.7;
    opacityRules = [ "100:class_g = 'dmenu'" ];
  };
}
