{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "neo";

    # TODO only laptops need this
    libinput = {
      enable = true;
      touchpad = {
        scrollMethod = "twofinger";
        disableWhileTyping = true;
      };
    };

    displayManager.lightdm.enable = true;

    desktopManager.xterm.enable = false;

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
