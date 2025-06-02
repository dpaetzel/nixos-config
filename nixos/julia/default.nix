{
  pkgs,
  config,
  lib,
  options,
  juliaEnv,
  ...
}:

with lib;
let
  cfg = config.dp.julia;
in
{
  imports = [ ];

  options.dp.julia.enable = mkEnableOption "Enable my Julia config";

  config = mkIf cfg.enable {

    home-manager.users.david.programs.fish.shellAliases = {
      j =
        let
          jjl = ./j.jl;
        in
        "${juliaEnv}/bin/julia --load ${jjl}";
      # julia = "julia -O 0";
      # jp = "julia -O 0 --project=.";
      killjulias = "ps aux | rg \'julia[^*]*worker\' | awk \'{ print $2 }\' | xargs kill";
    };

    home-manager.users.david.lib.file.".julia/config/startup.jl".source = ./startup.jl;
  };
}
