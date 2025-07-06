{ writeScriptBin }:


(writeScriptBin "wf" ''
#!/usr/bin/env fish


# Configuration of `clean` subcommand.
set allowed \
  1Projekte \
  2Bereiche \
  3Ressourcen \
  4Archiv \
  5Code \
  6Games \
  Inbox.md \
  Inbox \
  VMs \
  Outbox \
  Zettels
set inbox $HOME/Inbox


if set -q argv[1]
    set cmd $argv[1]
    set -e argv[1]

    switch $cmd
        case p
            begin
                command ls --quote -1 $HOME/1Projekte/
                command ls --quote -1 $HOME/Zettels/Zettels/1Projekte/
            end | sed -r 's/.md//' | sort | uniq

        case clean
            # Clean up the $HOME directory (moving anything not belonging there
            # to $inbox).

            set currentDir (pwd)
            cd $HOME
            mkdir -p $inbox

            for fname in *
                if not contains -- $fname $allowed
                    cd $inbox
                    if test -e "$fname"
                        echo "Archiving older versions of $fname …"
                        set archiveFilename (mktemp -u -d -p . "$fname-XXXXX")
                        mv "$fname" "$archiveFilename" 2>/dev/null
                    end
                    cd $HOME
                    echo "Cleaning $fname …"
                    mv "$fname" "$inbox"
                end
            end

            cd "$currentDir"
    end
end
'')
