{
  lib,
  config,
  options,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.dp.latex;
in
{
  imports = [ ];

  options.dp.latex.enable = mkEnableOption "Enable LaTeX the way I use it";

  config = mkIf cfg.enable {

    environment.systemPackages = [
      (pkgs.writeScriptBin "mkrefs" ''
        #!${pkgs.fish}/bin/fish

        find ~/Literatur \
            -iname '*.bib' \
            '!' -iname 'References.bib' \
            -exec echo '{}' \; \
            -exec awk '{print}; END {print "\n"}' '{}' \;
      '')
    ];
  };
}
