# Pi-Wallboard

This script will update a Raspbian image, and install Chromium.

It will then set the system to boot into a desktop with only Chromium running in kiosk mode, displaying a url stored in /etc/wallboard.conf

The script also creates 2 scripts tvoff.sh and tvon.sh
tvoff.sh which turns off the display - useful for sending displays to sleep. 
tvon.sh which simply reboots the pi therefore enabling the display - useful if the display recognises a feed and turns on automatically on detection.

Editing the crontab for root to change the times the on/off occurs will tailor it to your needs.
