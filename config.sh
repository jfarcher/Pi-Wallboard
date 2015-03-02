#!/bin/bash

echo "Starting Pi wallboard setup"
echo ""
echo "please make sure you are running as root (sudo -i)"
echo ""
echo "Please input the hostname you wish to use for this wallboard"
read hname
echo "Using: $hname"

echo "$hname" > /etc/hostname
hostname $hname

apt-get update
apt-get upgrade -y

apt-get install chromium vim x11-xserver-utils ttf-mscorefonts-installer xwit sqlite3 libnss3 unclutter puppet -y

sed -i s/START=no/START=yes/g /etc/default/puppet
update-rc.d lightdm enable 2
sed /etc/lightdm/lightdm.conf -i -e "s/^#autologin-user=.*/autologin-user=pi/"

cat <<EOF>/etc/xdg/lxsession/LXDE-pi/autostart
@xset s off
@xset -dpms
@xset s noblank
@unclutter -idle 0.1 -root
@chromium --kiosk \`cat /etc/wallboardurl.conf\`
EOF

cat <<EOF>/usr/local/sbin/tvon.sh
#!/bin/bash
/sbin/reboot
EOF
chmod +x /usr/local/sbin/tvon.sh

cat <<EOF>/usr/local/sbin/tvoff.sh
tvservice -o
EOF
chmod +x /usr/local/sbin/tvoff.sh
echo "disable_overscan=0" >>/boot/config.txt

cat <<EOF>/etc/wallboardurl.conf
http://status.aws.amazon.com/
EOF

cat <<EOF>>/var/spool/cron/crontabs/root
30 17 * * * /usr/local/sbin/tvoff.sh
00 08 * * * /usr/local/sbin/tvon.sh
EOF
chmod 600 /var/spool/cron/crontabs/root
/sbin/reboot
