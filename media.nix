{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "neo";

    # TODO hardware-dependent
    videoDrivers = [ "intel" ];

    # TODO only laptops needs this
    synaptics = {
      enable = true;
      minSpeed = "0.6";
      maxSpeed = "1.5";
      accelFactor = "0.015";
      twoFingerScroll = true;
      vertEdgeScroll = false;
      palmDetect = true;
    };

    # TODO autologin if hard drive is encrypted (thus device-dependent)
    displayManager.slim = {
      enable = true;
      defaultUser = "media";
      autoLogin = true;
      theme = pkgs.fetchurl {
        url = "https://github.com/edwtjo/nixos-black-theme/archive/v1.0.tar.gz";
        sha256 = "13bm7k3p6k7yq47nba08bn48cfv536k4ipnwwp1q1l2ydlp85r9d";
      };
    };

    desktopManager.kodi.enable = true;
  };
}
