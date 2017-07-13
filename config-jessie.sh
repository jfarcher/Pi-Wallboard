#!/bin/bash

echo "Starting Pi wallboard setup"
echo ""
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
else
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
passwd pi

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
echo "You should now configure the relevant areas on your puppet server to complete installation"
echo ""

apt-get update
apt-get remove wolfram-engine minecraft-pi geary scratch nodered sonic-pi libreoffice* -y
apt-get upgrade -y
apt-get install ttf-mscorefonts-installer -y

apt-get install puppet -y
puppet agent --enable

rm -rf /home/pi/.config/lxsession

/sbin/reboot
fi
