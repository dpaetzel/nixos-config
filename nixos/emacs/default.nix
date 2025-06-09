{
  lib,
  config,
  options,
  pkgs,
  inputs,
  configPath,
  ...
}:

with lib;
let
  cfg = config.dp.emacs;
in
{
  imports = [ ];

  options.dp.emacs.enable = mkEnableOption "Enable Emacs the way I use it";

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.emacs ];

    home-manager.users.david.xdg.configFile."doom" = {
      source = config.home-manager.users.david.lib.file.mkOutOfStoreSymlink "${configPath}/nixos/emacs/config/doom";
      recursive = false;
    };
  };
}
