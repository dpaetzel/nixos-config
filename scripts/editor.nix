{ writeShellScriptBin, myemacs }:

(writeShellScriptBin "editor" ''
  pgrep emacs \
    && ${myemacs}/bin/emacsclient --create-frame --no-wait $@ \
    || ${myemacs}/bin/emacs --tty $@
'')
