# home-manager configuration file of `anaxagoras` (replaces ~/.config/nixpkgs/home.nix).
{ pkgs, config, ... }:
{
  # Don't change this. Version that I originally installed home-manager with.
  #
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";

  imports = [ ../common/home.nix ];
}
