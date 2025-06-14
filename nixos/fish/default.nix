{
  pkgs,
  config,
  lib,
  options,
  pythonEnv,
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

      shellAliases = {
        p = "${pythonEnv}/bin/ipython --profile=p";
        pplot = "${pythonEnv}/bin/ipython --profile=p --matplotlib=auto";
        # Local shell in case I changed something but did not push yet.
        pl = "nix run path:/home/david/NixOS#pythonShell -- --profile=p";
        # No profile.
        pn = "${pythonEnv}/bin/ipython";
        mvt = "trash-put --verbose";
        # Unclear why this is not part of the `trash-*` utilities.
        trash-size = "du -hs ~/.local/share/Trash";
        rm = "echo Use `mvt` or `command rm`";
      };

      # TODO Extract from this to functions and aliases
      # Cannot really use home-manager's mkOutOfStoreSymlink here because fish
      # config is merged from multiple things (integrations etc.)
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


alias cp='cp --verbose --interactive'
alias mv='mv --verbose --interactive'


alias df='dfc'


alias g='git'
alias o='open'
alias ont='o (n t)'
alias onf='o (n f)'
alias oni='o (n i)'
# Trash the new file but ask me.
alias tnf='trash-put --verbose --interactive (n f)'
alias mutt='neomutt'
# from `man feh`: Scale images to fit window geometry
alias feh='feh --scale-down --theme=default'


alias m='udiskie-mount -ar'
alias mc='cd (udiskie-mount -ar | sed --regexp-extended "s/mounted .* on (.*)/\1/" | head -1)'
alias um='udiskie-umount -a'
# alias umoc='sudo umount -l /mnt/oc-h ; sudo umount -l /mnt/oc-m'
# alias moc='sudo mount /mnt/oc-h ; sudo mount /mnt/oc-m'


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

alias dt="date '+%F %T'"
      '';
    };
  };
}
