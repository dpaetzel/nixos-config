{ writeShellScriptBin, myemacs }:

# Note: I removed `--no-wait` to have the option of doing `emacsclient`
# synchronously. This means that all apps using `editor` have to add `--no-wait`
# if they require async.
(writeShellScriptBin "editor" ''
  pgrep emacs \
    && ${myemacs}/bin/emacsclient --create-frame "$@" \
    || ${myemacs}/bin/emacs --tty "$@"
'')
