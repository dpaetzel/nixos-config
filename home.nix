{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 86400;
    maxCacheTtl = 999999;
    # since gpg-agent is enabled here, we need to add the pinentry-program by
    # hand (see https://github.com/NixOS/nixpkgs/issues/73332)
    extraConfig = "pinentry-program ${pkgs.pinentry-gtk2}/bin/pinentry";
  };
}
