#!/bin/bash

inotifywait -m -r -e CLOSE_WRITE /etc/|while read file
do
        if (echo $file|grep wallboardurl.conf|grep -v sw)
        then
                echo "Restarting Browser"
                killall chromium-browser
                rm -rf /home/pi/.cache/chromium
                rm -rf /home/pi/.config/chromium

                sudo -u pi      DISPLAY=:0 /usr/bin/chromium-browser --noerrdialogs --disable-session-crashed-bubble --disable-infobars --kiosk --no-first-run `cat /etc/wallboardurl.conf`&
        fi
done


