#!/bin/bash

inotifywait -m -r -e CLOSE_WRITE /etc/|while read file
do
        if (echo $file|grep wallboardurl.conf|grep -v sw)
        then
                echo "Restarting Browser"
                killall chromium
                sudo -u pi      DISPLAY=:0 chromium --kiosk `cat /etc/wallboardurl.conf`&
        fi
done

