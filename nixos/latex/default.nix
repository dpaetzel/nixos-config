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

        find $HOME/3Ressourcen/Literatur \
            -iname '*.bib' \
            '!' -iname 'References.bib' \
            -exec echo '{}' \; \
            -exec awk '{print}; END {print "\n"}' '{}' \;
      '')

      (pkgs.writeScriptBin "sources" ''
        #!${pkgs.fish}/bin/fish

        if test -z "$argv"
            echo *.tex
            cat *.tex | grep -E '\\\\input{' | sed -E 's/.*\\\\input\{(.*)\}.*/\1.tex/'
            cat *.tex | grep -E '\\\\include{' | sed -E 's/.*\\\\include\{(.*)\}.*/\1.tex/'
            cat *.tex | grep -E '\\\\bibliography{' | sed -E 's/.*\\\\bibliography\{(.*)\}.*/\1.bib/'
        else
            echo $argv
            cat $argv | grep -E '\\\\input{' | sed -E 's/.*\\\\input\{(.*)\}.*/\1.tex/'
            cat $argv | grep -E '\\\\include{' | sed -E 's/.*\\\\include\{(.*)\}.*/\1.tex/'
            cat $argv | grep -E '\\\\bibliography{' | sed -E 's/.*\\\\bibliography\{(.*)\}.*/\1.bib/'
        end
      '')

      (pkgs.writeScriptBin "lit" ''
        #!${pkgs.fish}/bin/fish

        if test "$argv[1]" != "" -a "$argv[2]" != "" -a "$argv[3]" != "" -a "$argv[4]" != ""
            set -l num
            if test "$argv[5]" = ""
                set num ""
            else
                set num "$argv[5]"
            end

            set -l pdf "$argv[1]"
            set -l author "$argv[2]"
            set -l year "$argv[3]"
            set -l title "$argv[4]"

            set -l short "$author$year"
            set -l long "$year $title"

            if test -d "$HOME/3Ressourcen/Literatur/$short$num"
                if test "$num" = ""
                    lit "$pdf" "$author" "$year" "$title" "b"
                else
                    lit "$pdf" "$author" "$year" "$title" (chr (math (ord "$num") + 1))
                end
            else
                echo "Creating $HOME/3Ressourcen/Literatur/$short$num"
                mkdir "$HOME/3Ressourcen/Literatur/$short$num"
                mv "$pdf" "$HOME/3Ressourcen/Literatur/$short$num/$long.pdf"
            end
        end
      '')

      (pkgs.writeScriptBin "bib" ''
        #!${pkgs.fish}/bin/fish

        if test "$argv[1]" != "" -a "$argv[2]" != ""
            set -l file "$argv[1]"
            set -l name "$argv[2]"

            editor "$file"
            and cp "$file" "$HOME/3Ressourcen/Literatur/$name/$name.bib"
            and trash-put "$file"
        end
      '')
    ];
  };
}
