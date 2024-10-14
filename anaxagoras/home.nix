# home-manager configuration file of `anaxagoras` (replaces ~/.config/nixpkgs/home.nix).
{ pkgs, ... }:
{
  # Don't change this. Version that I originally installed home-manager with.
  #
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";

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
