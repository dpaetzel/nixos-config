{
  lib,
  config,
  options,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.dp.fish;
in
{
  imports = [ ];

  options.dp.fish.enable = mkEnableOption "Enable my Fish config";

  config = mkIf cfg.enable {
    # Consider to use hlissner's abstraction here instead of
    # `home-manager.users.david`, see
    # https://github.com/hlissner/dotfiles/blob/master/modules/home.nix#L78

    home-manager.users.david.programs = {
        direnv.enableFishIntegration = true;
        eza.enableFishIntegration = true;
        fzf.enableFishIntegration = true;
        kitty.shellIntegration.enableFishIntegration = true;
    };

    home-manager.users.david.services.gpg-agent.enableFishIntegration = true;

    home-manager.users.david.programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };

    home-manager.users.david.programs.fish = {
      enable = true;
      functions = {
        # Echo newly created files
        n = ''
          if test $argv[1] = "f"
            command ls --sort time (find $argv[2] -maxdepth 1 -type f \! -path './.*') | head -1
          else if test $argv[1] = "d"
            command ls --directory --sort time (find -maxdepth 1 -type d \! -path './.*' \! -name '.') | head -1
          end
        '';
        # Analyse the size of directories.
        lsd = ''
          for d in (find . -maxdepth 2 -mindepth 2 -type d)
              du -h --dereference "$d" | tail -1
          end
        '';
        # Create the destination directory, then move the files there.
        mvc = ''
          if test (count $argv) -gt 1
              mkdir -p $argv[-1]
              mv $argv
          else
              echo "Not enough arguments given"
          end
        '';
        # Sort images.
        sortimgs = ''
          set -l folder (mktemp -d -p .)
          feh --action "mv '%f' $folder" --action1 "mkdir TRASH; mv '%f' TRASH" $argv
          command ls $folder
          read name
          mv "$folder" "$name"
        '';
        # Select images.
        selimgs = ''
          set -l folder (mktemp -d -p .)
          feh --action "cp '%f' $folder" --action1 "mkdir TRASH; mv '%f' TRASH" $argv
          command ls $folder
          read name
          mv "$folder" "$name"
        '';
      };

      # TODO Extract from this to functions and aliases
      shellInit = ''
        # Fixes strange output when Emacs runs Fish
        # https://github.com/fish-shell/fish-shell/issues/1155#issuecomment-420962831
        if ! test "$TERM" = "dumb"
            fish_vi_key_bindings
        end

        # Fixes Emacs TRAMP (i.e. when I open files on this machine from a
        # remote machine via SSH).
        if test "$TERM" = "dumb"
          function fish_prompt
            echo "\$ "
          end

          function fish_right_prompt; end
          function fish_greeting; end
          function fish_title; end
        end

set -xg PATH $PATH "$HOME/5Code/utility"
set -xg INBOX "$HOME/Inbox"


# default folder for mates
# set -xg MATES_DIR ~/.kontakte
# mates binary is in .cargo/bin
# set -xg PATH $PATH $HOME/.cargo/bin


set fish_greeting


# Workaround for https://github.com/fish-shell/fish-shell/issues/5994.
set -x PAGER less -R


# Fixes strange output when Emacs runs Fish
# https://github.com/fish-shell/fish-shell/issues/1155#issuecomment-420962831
# if ! test "$TERM" = "dumb"
#     fish_vi_key_bindings
# end


# Fixes Emacs TRAMP (i.e. when I open files on this machine from a remote
# machine via SSH).
# if test "$TERM" = "dumb"
#   function fish_prompt
#     echo "\$ "
#   end

#   function fish_right_prompt; end
#   function fish_greeting; end
#   function fish_title; end
# end


direnv hook fish | source


# https://gist.github.com/josh-padnick/c90183be3d0e1feb89afd7573505cab3?permalink_comment_id=3806363#gistcomment-3806363
# if test -z (pgrep ssh-agent | string collect)
#     eval (ssh-agent -c)
#     set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
#     set -Ux SSH_AGENT_PID $SSH_AGENT_PID
# end
# We use gnupg agent instead (see NixOS configuration).


alias s='sudo'


alias ls='exa'
alias l='exa'
alias ll='exa -l'
alias la='ls -a'
alias lla='ll -a'
alias tree='exa --tree'
alias lld='du -h | grep \'\./[^/]\+$\' | sed -e "s/\(.*\)\.\/\(.*\)/\1\2/"'
# function n --description='Echo newly created files'
#   if test -z "$argv"; or test "$argv" = "t"
#     echo $TEMPORARY/(command ls --sort time $TEMPORARY | head -1)
#   else if test $argv[1] = "f"
#     command ls --sort time (find $argv[2] -maxdepth 1 -type f \! -path './.*') | head -1
#   else if test $argv[1] = "d"
#     command ls --directory --sort time (find -maxdepth 1 -type d \! -path './.*' \! -name '.') | head -1
#   else if test -z $argv; or test $argv = "t"
#     echo $INBOX/(command ls --sort time $TEMPORARY | head -1)
#   end
# end
# Analyse the size of directories.
# function lsd
#     for d in (find . -maxdepth 2 -mindepth 2 -type d)
#         du -h --dereference "$d" | tail -1
#     end
# end


# Short for Python here (e.g. if I'm in a dev shell).
alias ph="ipython --profile=p"


alias cp='cp --verbose --interactive'
alias mv='mv --verbose --interactive'
# function mvc --wraps=mv --description='Create the destination directory, then move the files there'
#   if test (count $argv) -gt 1
#       mkdir -p $argv[-1]
#       mv $argv
#   else
#       echo "Not enough arguments given"
#   end
# end


alias x='chmod +x'


alias df='dfc'


alias g='git'
alias led="ledger -f $HOME/Buchhaltung/Gesamt.ledger"
alias o='open'
alias ont='o (n t)'
alias onf='o (n f)'
alias oni='o (n i)'
# Trash the new file but ask me.
alias tnf='trash-put --verbose --interactive (n f)'
alias mutt='neomutt'
# from `man feh`: Scale images to fit window geometry
alias feh='feh --scale-down --theme=default'


# function sortimgs
#     set -l folder (mktemp -d -p .)
#     feh --action "mv '%f' $folder" --action1 "mkdir TRASH; mv '%f' TRASH" $argv
#     command ls $folder
#     read name
#     mv "$folder" "$name"
# end


# function selimgs
#     set -l folder (mktemp -d -p .)
#     feh --action "cp '%f' $folder" --action1 "mkdir TRASH; mv '%f' TRASH" $argv
#     command ls $folder
#     read name
#     mv "$folder" "$name"
# end


# Did not copy that one, did not use it ever again.
# function sortzets
#     set -l folder (mktemp -d -p .)
#     for f in *.md
#         grep "^# " $f
#         read -P "Is it work? [y/N]" -l reply
#         if test "X$reply" = "Xy"
#             mv $f $folder
#         end
#     end
#     read name
#     mv "$folder" "$name"
# end


alias m='udiskie-mount -ar'
alias mc='cd (udiskie-mount -ar | sed --regexp-extended "s/mounted .* on (.*)/\1/" | head -1)'
alias um='udiskie-umount -a'
# alias umoc='sudo umount -l /mnt/oc-h ; sudo umount -l /mnt/oc-m'
# alias moc='sudo mount /mnt/oc-h ; sudo mount /mnt/oc-m'
alias moc="mkdir -p ~/ocm ; sudo moc mount --types cifs --options vers=3.0,credentials=/home/david/.credentials,uid=1000 '//cfs-informatik.informatik.uni-augsburg.de/oc-m' ~/ocm"
alias umoc='sudo umount -l ~/ocm'


alias tnat='nix-shell -p python3 --command "curl -fsSl https://raw.githubusercontent.com/tridactyl/tridactyl/master/native/install.sh | bash"'


# alias plotting='nix-shell -p gnuplot haskellPackages.cassava haskellPackages.gnuplot ghc'
alias plotting='nix-shell -p "haskellPackages.ghcWithPackages (pkgs : [ pkgs.cassava pkgs.easyplot ])" gnuplot'
alias plottingNoEasy='nix-shell -p "haskellPackages.ghcWithPackages (pkgs : [ pkgs.cassava ])" gnuplot'


set format "{calendar-color}{cancelled}{start-end-time-style} {title} [{location}]{repeat-symbol}{reset}"
set format_long "{calendar-color}{cancelled}{start-end-time-style} ({calendar}) {title} [{location}]{repeat-symbol}{reset}"
function c
    khal \
        --color \
        list \
        --format "$format" \
        -a Pause \
        -a Arbeit~ \
        -a Arbeit \
        -a OC \
        -a Ich \
        -a Beide \
        -a Geburtstage \
        $argv \
        | sed "s/ \?\[\]//"
end
function cal
    khal \
        --color \
        list \
        --format "$format_long" \
        $argv \
        | sed "s/ \?\[\]//"
end
function calt
    khal \
        --color \
        list \
        --format "$format_long" \
        today \
        today \
        | sed "s/ \?\[\]//"
end
function ical
    ikhal
end
alias arbeit='khal new --calendar Arbeit --alarms 1d,2h,1h'
alias arbeit~='khal new --calendar Arbeit~ --alarms 10m,0m'
alias pause='khal new --calendar Pause --alarms 0m'
alias ich='khal new --calendar Ich --alarms 1d,2h,1h'
alias beide='khal new --calendar Beide --alarms 1d,2h,1h'
alias regine='khal new --calendar Regine --alarms 1d,2h,1h'
alias urlaubocm='math 10 + 30 + 30 + 30 - 4 - (math (command ls /mnt/oc-m/Verwaltung/Urlaubsantraege/Pätzel/ | sed -E "s/.*_([[:digit:]]+)Tag.*/\1/" | paste -sd+))'
# The “- 4” is a correction from an email from 2020-11-04.
alias urlaub='math 10 + 30 + 30 + 30 - 4 - (math (command ls $HOME/Dokumente/arbeit/urlaubsanträge | sed -E "s/.*_([[:digit:]]+)Tag.*/\1/" | paste -sd+))'
function cpull
    khal list --include-calendar Arbeit~ now tomorrow --day-format ""
end


function mkrefs
    find ~/Literatur \
        -iname '*.bib' \
        '!' -iname 'References.bib' \
        -exec echo '{}' \; \
        -exec awk '{print}; END {print "\n"}' '{}' \;
end


function texr
    if test "$argv" = "--fix"
        entr fish -c "mkrefs > References.bib ; latexmk -f $argv | grep -v 'characters of junk seen' ; fixfonts out/*.pdf"
    else
        entr fish -c "mkrefs > References.bib ; latexmk -f $argv | grep -v 'characters of junk seen'"
    end
end
function texrnon
    if test "$argv" = "--fix"
        entr fish -c "mkrefs > References.bib ; latexmk -f -interaction=nonstopmode $argv | grep -v 'characters of junk seen' ; fixfonts out/*.pdf"
    else
        entr fish -c "mkrefs > References.bib ; latexmk -f -interaction=nonstopmode $argv | grep -v 'characters of junk seen'"
    end
end
function texrl
    if test "$argv" = "--fix"
        entr fish -c "mkrefs > References.bib ; latexmk -f -interaction=nonstopmode -norc -r ./.latexmkrc $argv | grep -v 'characters of junk seen' ; fixfonts out/*.pdf"
    else
        entr fish -c "mkrefs > References.bib ; latexmk -f -interaction=nonstopmode -norc -r ./.latexmkrc $argv | grep -v 'characters of junk seen'"
    end
end


function sources
    if test -z "$argv"
        echo *.tex
        cat *.tex | grep -E '\\\\input{' | sed -E 's/.*\\\\input\{(.*)\}.*/\1.tex/'
        cat *.tex | grep -E '\\\\include{' | sed -E 's/.*\\\\include\{(.*)\}.*/\1.tex/'
        cat *.tex | grep -E '\\\\bibliography{' | sed -E 's/.*\\\\bibliography\{(.*)\}.*/\1.bib/'
    else
        echo $argv
        cat $argv | grep -E '\\\\input{' | sed -E 's/.*\\\\input\{(.*)\}.*/\1.tex/'
        cat *.tex | grep -E '\\\\include{' | sed -E 's/.*\\\\include\{(.*)\}.*/\1.tex/'
        cat $argv | grep -E '\\\\bibliography{' | sed -E 's/.*\\\\bibliography\{(.*)\}.*/\1.bib/'
    end
end


function hearthstone
    set -x WINEPREFIX "$HOME/Spiele/Hearthstone"
    wine "C:/Program Files/Battle.net/Battle.net Launcher.exe"
end


function qt
    # if test $argv[1] = "--system"
    #     set -l PATH (echo $PATH | sed 's#/home/david/.nix-profile/bin ##')
    # else if test $argv[1] = "--user"
    #     set -l PATH (echo $PATH | sed 's#/run/current-system/sw/bin ##')
    # else
    #     echo "Either use --system or --user parameter"
    set -l p $PATH
    echo $argv[1]
    echo $argv[2]
    if test $argv[1] = "--system"
        set PATH /run/current-system/sw/bin
    else if test $argv[1] = "--user"
        set PATH home/david/.nix-profile/bin
    else
        echo "Either use --system or --user parameter"
    end

    eval $argv[2]

    set PATH $p
end


function ord
    echo "$argv" | od -A n -t d1 | read -l addr num ;and echo $addr
end


function chr
    printf "%b\n" '\0'(printf '%o\n' "$argv")
end


function lit
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

        if test -d "$HOME/Literatur/$short$num"
            if test "$num" = ""
                lit "$pdf" "$author" "$year" "$title" "b"
            else
                lit "$pdf" "$author" "$year" "$title" (chr (math (ord "$num") + 1))
            end
        else
            echo "Creating Literatur/$short$num"
            mkdir "$HOME/Literatur/$short$num"
            mv "$pdf" "$HOME/Literatur/$short$num/$long.pdf"
        end
    end
end


function bib
    if test "$argv[1]" != "" -a "$argv[2]" != ""
        set -l file "$argv[1]"
        set -l name "$argv[2]"

        editor "$file"
        and cp "$file" "$HOME/Literatur/$name/$name.bib"
        and mvt "$file"
    end
end


function allpass
    for f in (find ~/.password-store/ -type f -iname '*.gpg' | sed -r 's/^.*store\///;s/.gpg$//')
        set -l IFS
        set content (pass "$f")
        set pw (echo "$content" | head -1)
        echo "$f: $pw"
    end
end


function checkpass
    for f in (find ~/.password-store/ -type f -iname '*.gpg' | sed -r 's/^.*store\///;s/.gpg$//')
        set -l IFS
        set content (pass "$f")
        set pw (echo "$content" | head -1)
        if test (string length -- "$pw") -lt 25
            if test (echo "$content" | tail -1) != "Regeln"
              echo "$f: $pw"
            end
        end
    end
end


function mkmail
    mkdir -p "$argv"/{cur,new,tmp}
end


function cinit
    cabal init \
        --cabal-version=2.2 \
        --dependency="base >=4.12.0.0 && < 4.14" \
        --dependency=rio \
        --dependency=QuickCheck \
        --source-dir=src \
        --category="" \
        --homepage="" \
        --synopsis="" \
        --language=Haskell2010 \
        --main-is=src/Main.hs \
        --license="GPL-3" \
        --no-comments

    set name (grep "^name: " *.cabal | sed "s/^name: *//")
    echo "(import ./release.nix).$name.env" > shell.nix
    echo "
    let
    config = {
    packageOverrides = pkgs: rec {
    haskellPackages = pkgs.haskellPackages.override {
    overrides = haskellPackagesNew: haskellPackagesOld: rec {
    # NOTE to enable profiling in all other libraries (to enable for
    # haxcs, add ghc-options)
    # mkDerivation = args: super.mkDerivation (args // {
    #   enableLibraryProfiling = true;
    # });

    cabal-test-quickcheck = with pkgs.haskell.lib;
    doJailbreak (unmarkBroken haskellPackagesOld.cabal-test-quickcheck);

    $name = haskellPackagesNew.callPackage ./default.nix { };
    };
    };
    };
    };
    pkgs = import <nixpkgs> { inherit config; };
    in { $name = pkgs.haskellPackages.$name; }
    " > release.nix
    nixfmt release.nix
    cabal2nix > default.nix
end


alias update-spacemacs="\
cd ~/.emacs.d && \
git pull --rebase; \
find ~/.emacs.d/elpa/2*/develop/org-plus-contrib* -name '*.elc' -delete"


function gong
    date
    for t in $argv
        sleep $t
        mpv --really-quiet "$HOME/.Gong.mp3" &
    end
    date
end


function ring
    date
    for t in $argv
        sleep $t
        mpv --really-quiet "$HOME/.Ring.mp3" &
    end
end


alias randid="cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1"
function camera
    ffmpeg -f v4l2 -video_size 1920x1080 -i /dev/video0 -c:v libx264 -preset ultrafast (date -I)\ "$argv.mp4"
end


alias neu="neuron -d $HOME/Zettels"


alias vpn="nmcli con up uni-vpn-neu"
alias vpnd="nmcli con down uni-vpn-neu"


alias bd="bg ;and disown"


# Naively check for mem leaks (if it does not sum to something close to 100%,
# something is leaking).
# python -c (ps -eo %mem --sort=-%mem | tail +2 | tr -s '\n' ',' | sed 's/^/print(sum([/;s/$/]))/')


alias dr="direnv reload"
alias nfu="nix flake update"
alias bias="feh ~/.cognitive-bias-codex.png"


function cix-shell
    nix develop --profile .dev-profile --command date
    cachix push $argv .dev-profile
end


function cix-in
    nix flake archive --json \
        | jq -r '.path,(.inputs|to_entries[].value.path)' \
        | cachix push $argv
end


function cix-runtime
    nix build --json \
        | jq -r '.[].outputs | to_entries[].value' \
        | cachix push $argv
end


alias abduco="abduco -e ^q"

alias julia="julia -O 0"
alias jp="julia -O 0 --project=."
alias killjulias='ps aux | rg \'julia[^*]*worker\' | awk \'{ print $2 }\' | xargs kill'
alias ssh="kitten ssh"
alias dt="date '+%F %T'"
function zets -d "List Zettels by file path and title"
    set paths $argv
    set -l expanded_paths
    if test (count $paths) -eq 0
        set expanded_paths **.md
    else
        # Expand any directories provided recursively.
        for path in $paths
            if test -d $path
                set expanded_paths $expanded_paths $path/**.md
            else
                set expanded_paths $expanded_paths $path
            end
        end
    end

    for fpath in $expanded_paths
        # Print the first toplevel heading.
        command awk '/^# /{print FILENAME " : " $0; exit}' $fpath
    end
end
      '';
    };
  };
}
