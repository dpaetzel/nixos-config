{ writeShellScriptBin, myemacs }:

(writeShellScriptBin "editor" ''
  pgrep emacs && ${myemacs}/bin/emacsclient -n $@ || ${myemacs}/bin/emacs -nw $@
'')
