{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 86400;
    maxCacheTtl = 999999;
    extraConfig = "pinentry-program ${pkgs.pinentry-gtk2}/bin/pinentry";
  };
}
