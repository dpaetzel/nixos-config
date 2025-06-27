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
  jjl = ./j.jl;
  startupjl = ./startup.jl;
in
{
  imports = [ ];

  options.dp.julia.enable = mkEnableOption "Enable my Julia config";

  config = mkIf cfg.enable {

    home-manager.users.david.programs.fish.shellAliases = {
      j = "${juliaEnv}/bin/julia --load ${jjl}";
      # julia = "julia -O 0";
      # jp = "julia -O 0 --project=.";
      killjulias = "ps aux | rg \'julia[^*]*worker\' | awk \'{ print $2 }\' | xargs kill";
    };

    home-manager.users.david.lib.file.".julia/config/startup.jl".source = startupjl;

    # A long-running session so that I have <1s to plot.
    home-manager.users.david.systemd.user.services.julia-daemon = {
      Unit = {
        Description = "Julia REPL with abduco";
        After = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        # The issue is that systemd thinks the tmux command has "completed"
        # because the started program forks into the background. You need to use
        # Type=forking instead of Type=exec.
        Type = "forking";
        Environment = [
          "TERM=xterm-kitty"
          "COLORTERM=truecolor"
          "JULIA_COLOR=yes"
        ];
        ExecStart =
          let
            juliaWrapper = pkgs.writeShellScript "julia-abduco-wrapper" ''
              # Export environment for Julia
              export TERM="xterm-kitty"
              export COLORTERM="truecolor"
              export JULIA_COLOR="yes"

              # Start abduco with Julia
              exec ${pkgs.abduco}/bin/abduco -n julia-repl \
                ${juliaEnv}/bin/julia --color=yes --load ${jjl}
            '';
          in
          "${juliaWrapper}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # Connection script to connect to the long-running Julia session.
    # Disconnect by default by Ctrl+\.
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "julia-connect" ''
        if ! ${pkgs.abduco}/bin/abduco -l | grep -q julia-repl; then
          echo "Starting Julia daemon..."
          systemctl --user start julia-daemon
          sleep 2
        fi

        # Open new Kitty window with abduco session
        exec ${pkgs.kitty}/bin/kitty \
          --title "Julia REPL" \
          ${pkgs.abduco}/bin/abduco -a julia-repl
      '')
    ];
  };
}
