#!/bin/bash
echo "Starting Pi wallboard setup"
echo ""
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
else

echo "Starting Pi wallboard setup"
echo ""
echo "Please input the hostname you wish to use for this wallboard"
read hname
echo "Using: $hname"
echo "Please enter the local domain suffix eg. example.com"
read dname
echo "FQDN will be $hname.$dname"

echo "$hname" > /etc/hostname
sed '/^127.0.0.1/ d' -i /etc/hosts
echo "127.0.0.1 $hname.$dname $hname localhost" >> /etc/hosts
/etc/init.d/hostname.sh
echo ""

echo "Lets reset the password for the pi user"
echo "Please make sure you store this in the password safe"
passwd pi
echo ""

echo "Please enter the URL to be displayed"
read url
if [ ! -z $url ]; then
url = http://status.aws.amazon.com/
fi
echo "Using: $url"
cat <<EOF>/etc/wallboardurl.conf
$url
EOF

while true; do
    read -p "Will you be using puppet to control your display board? (Y/N)" yn
    case $yn in
        [Yy]* ) puppet=1; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Does your Pi require the use of a proxy to gain access to the internet? (Y/N)" yn
    case $yn in
	[Yy]* ) echo "Please enter the proxy server (http://server:port)"; read proxy;break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

if [ ! -z $proxy ]; then
cat <<EOF> /etc/apt/apt.conf.d/00proxy
Acquire::http::Proxy "$proxy";
EOF
export http{,s}_proxy="$proxy"
fi




echo ""
echo "Thanks, The digital display will now continue installing you probably have enough time to make a brew!"
echo "Once the install completes it will automatically reboot and you should see the desired display"
echo "If you are using puppet to control the URL displayed, you can now place a config file on your puppetmaster."
echo ""


apt-get update
apt-get upgrade -y
apt-get install chromium vim x11-xserver-utils xwit sqlite3 libnss3 unclutter ttf-mscorefonts-installer openjdk-7-jdk icedtea-7-plugin -y
ln -s /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/IcedTeaPlugin.so /usr/lib/chromium/plugins/IcedTeaPlugin.so


update-rc.d lightdm enable 2
sed /etc/lightdm/lightdm.conf -i -e "s/^#autologin-user=.*/autologin-user=pi/"
sed /etc/default/unclutter -i -e "s/-idle 1/-idle 0.1/g"

cat <<EOF>/etc/xdg/lxsession/LXDE-pi/autostart
@xset s off
@xset -dpms
@xset s noblank
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

rev="`uname -m`"
if [ "$rev" == "armv6l" ]; then
echo "Pi 1"
echo "disable_overscan=0" >>/boot/config.txt
fi

if [ "$rev" == "armv7l" ]; then
echo "Pi 2"
echo "disable_overscan=1" >>/boot/config.txt
fi


cat <<EOF>>/var/spool/cron/crontabs/root
30 17 * * * /usr/local/sbin/tvoff.sh
00 08 * * * /usr/local/sbin/tvon.sh
EOF
chmod 600 /var/spool/cron/crontabs/root

###puppet
if [ $puppet == "1" ]; then
apt-get install puppet -y
sed -i s/START=no/START=yes/g /etc/default/puppet
puppet agent -t
puppet agent -t
else
cat <<EOF> /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# Print the IP address
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi
/usr/local/sbin/restart-browser.sh
exit 0
EOF

cat <<EOF> /usr/local/sbin/restart-browser.sh
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
EOF
fi

/sbin/reboot
fi
