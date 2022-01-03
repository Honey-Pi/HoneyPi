[ -z $BASH ] && { exec bash "$0" "$@" || exit; }
#!/bin/bash
# file: install.sh
#
# This script will install required software for HoneyPi.
# It is recommended to run it in your home directory.
#

# check if sudo is used
if [ "$(id -u)" != 0 ]; then
  echo 'Sorry, you need to run this script with sudo'
  exit 1
fi

if [ -z "$1" ] ; then
    echo "Info: No argument for stable/pre-release. Default is stable."
    stable=1
else
    stable=$1
fi

# replace symbolic link to use bash as default shell interpreter
echo '>>> Use bash as default shell interpreter'
ln -s bash /bin/sh.bash
mv /bin/sh.bash /bin/sh

# set locale to reduce debug messages
echo '>>> Set locale to en_GB.UTF-8'
export LANGUAGE=en_GB.UTF-8
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8
locale-gen en_GB.UTF-8
dpkg-reconfigure -f noninteractive locales

# target directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# default gpio for Ds18b20, per default raspbian would use gpio 4
w1gpio=11

# sys update
echo '>>> System update'
apt-get update && apt-get upgrade -y

# enable I2C on Raspberry Pi
# enable 1-Wire on Raspberry Pi
echo '>>> Enable I2C and 1-Wire'
if grep -q '^i2c-dev' /etc/modules; then
  echo '1 - Seems i2c-dev module already exists, skip this step.'
else
  echo 'i2c-dev' >> /etc/modules
fi
if grep -q '^w1_gpio' /etc/modules; then
  echo '2 - Seems w1_gpio module already exists, skip this step.'
else
  echo 'w1_gpio' >> /etc/modules
fi
if grep -q '^w1_therm' /etc/modules; then
  echo '3 - Seems w1_therm module already exists, skip this step.'
else
  echo 'w1_therm' >> /etc/modules
fi
if grep -q '^dtoverlay=w1-gpio' /boot/config.txt; then
  echo '4 - Seems w1-gpio parameter already set, skip this step.'
else
  echo 'dtoverlay=w1-gpio,gpiopin='$w1gpio >> /boot/config.txt
fi
if grep -q '^dtparam=i2c_arm=on' /boot/config.txt; then
  echo '5 - Seems i2c_arm parameter already set, skip this step.'
else
  echo 'dtparam=i2c_arm=on' >> /boot/config.txt
fi

# Enable Wifi-Stick on Raspberry Pi 1 & 2
if grep -q 'net.ifnames=0' /boot/cmdline.txt; then
    echo '6 - Seems net.ifnames=0 parameter already set, skip this step.'
else
    sed -i '1s/$/ net.ifnames=0/' /boot/cmdline.txt
fi

# Code to run only on raspberry zero
if grep -q 'Zero' /proc/device-tree/model; then
    serial=0
    if [ $serial -eq 1 ] ; then
        echo '>>> Configuring Serial Login for Raspberry Zero'
        # To see if the line needs to be appended
        dt=$(cat /boot/config.txt | grep "dtoverlay=dwc2")
        if [ "$dt" != "dtoverlay=dwc2" ]; then
            echo "dtoverlay=dwc2" >> /boot/config.txt
        fi
        # To see if the line needs to be appended
        mod=$(cat /boot/cmdline.txt | grep -o "modules-load=dwc2,g_serial")
        if [ "$mod" != "modules-load=dwc2,g_serial" ]; then
            sed -i '1s/$/ modules-load=dwc2,g_serial/' /boot/cmdline.txt
        fi
        echo 'g_serial' >> /etc/modules
        systemctl enable serial-getty@ttyGS0.service

    else
        echo '>>> Configuring usb0 SSH Login for Raspberry Zero'
        # To see if the line needs to be appended
        dt=$(cat /boot/config.txt | grep "dtoverlay=dwc2")
        if [ "$dt" != "dtoverlay=dwc2" ]; then
            echo "dtoverlay=dwc2" >> /boot/config.txt
        fi
        # To see if the line needs to be appended
        mod=$(cat /boot/cmdline.txt | grep -o "modules-load=dwc2,g_ether")
        if [ "$mod" != "modules-load=dwc2,g_ether" ]; then
            sed -i '1s/$/ modules-load=dwc2,g_ether/' /boot/cmdline.txt
        fi
    fi
else
    echo '>>> Info: This is not a Raspberry Zero, skip this step.'
fi

# Add a timeout for waiting for interfaces (in case no internet is connected)
#mkdir -p /etc/systemd/system/networking.service.d/
#bash -c 'echo -e "[Service]\nTimeoutStartSec=60sec" > /etc/systemd/system/networking.service.d/timeout.conf'
#systemctl daemon-reload

# Change timezone in Debian 9 (Stretch)
echo '>>> Change Timezone to Berlin'
ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# change hostname to http://HoneyPi.local
echo '>>> Change Hostname to HoneyPi'
sed -i 's/127.0.1.1.*raspberry.*/127.0.1.1 HoneyPi/' /etc/hosts
bash -c "echo 'HoneyPi' > /etc/hostname"

# Install NTP for time synchronisation with wittyPi
echo '>>> Install NTP for time synchronisation with wittyPi'
apt-get install -y ntp
dpkg-reconfigure -f noninteractive ntp

# rpi-scripts
echo '>>> Install software for measurement python scripts'
apt-get install -y rpi.gpio python-smbus python-setuptools python3-pip libatlas-base-dev libgpiod2
pip3 install -r requirements.txt

# required since version v1.3.7
echo '>>> Install software for v1.3.7'
apt-get -y install libopenjp2-7 libtiff5

# rpi-webinterface
echo '>>> Install software for Webinterface'
apt-get install -y lighttpd php-cgi
lighttpd-enable-mod fastcgi fastcgi-php
cp overlays/lighttpd.conf /etc/lighttpd/lighttpd.conf
chmod -R 644 /etc/lighttpd/lighttpd.conf
service lighttpd force-reload

echo '>>> Create www-data user'
groupadd www-data
usermod -G www-data -a pi

# give www-data all right for shell-scripts
echo '>>> Give shell-scripts rights'
if grep -q 'www-data ALL=NOPASSWD: ALL' /etc/sudoers; then
  echo 'Seems www-data already has the rights, skip this step.'
else
  echo 'www-data ALL=NOPASSWD: ALL' | EDITOR='tee -a' visudo
fi

# Install software for surfstick
echo '>>> Install software for Surfsticks'
apt-get install -y wvdial usb-modeswitch usb-modeswitch-data
cp overlays/wvdial.conf /etc/wvdial.conf
cp overlays/wvdial.conf.tmpl /etc/wvdial.conf.tmpl
chmod 755 /etc/wvdial.conf
cp overlays/wvdial /etc/ppp/peers/wvdial

#echo '>>> Put wvdial into Autostart'
#if grep -q "connection.sh" /etc/rc.local; then
#  echo 'Seems connection.sh already in rc.local, skip this step.'
#else
#  sed -i -e '$i \(sh '"$DIR"'/rpi-scripts/shell-scripts/connection.sh)&\n' /etc/rc.local
#  chmod +x /etc/rc.local
#  systemctl enable rc-local.service
#fi

# wifi networks
echo '>>> Setup Wifi Configuration'
if grep -q 'network={' /etc/wpa_supplicant/wpa_supplicant.conf; then
  echo 'Seems networks are configure, skip this step.'
else
  cp overlays/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
  echo 'Remember to configure your WiFi credentials in /etc/wpa_supplicant/wpa_supplicant.conf'
  chmod -R 600 /etc/wpa_supplicant/wpa_supplicant.conf
  chmod +x /etc/wpa_supplicant/wpa_supplicant.conf
fi
cp overlays/dhcpcd.conf /etc/dhcpcd.conf

# Autostart
echo '>>> Put Measurement Script into Autostart'
if grep -q "$DIR/rpi-scripts/main.py" /etc/rc.local; then
  echo 'Seems measurement main.py already in rc.local, skip this step.'
else
  sed -i -e '$i \(sleep 2;python3 '"$DIR"'/rpi-scripts/main.py)&\n' /etc/rc.local
  chmod +x /etc/rc.local
  systemctl enable rc-local.service
fi

# AccessPoint
echo '>>> Set Up Raspberry Pi as Access Point'
apt-get install -y dnsmasq hostapd
systemctl disable dnsmasq
systemctl disable hostapd || (systemctl unmask hostapd && systemctl disable hostapd)
systemctl stop dnsmasq
systemctl stop hostapd

#Start in client mode
# Configuring the DHCP server (dnsmasq)
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
cp overlays/dnsmasq.conf /etc/dnsmasq.conf
# Configuring the access point host software (hostapd)
cp overlays/hostapd.conf.tmpl /etc/hostapd/hostapd.conf.tmpl
cp overlays/hostapd /etc/default/hostapd

echo

# waiting for internet connection
echo ">>> Waiting for internet connection ..."
while ! timeout 0.2 ping -c 1 -n api.github.com &> /dev/null
do
printf "."
done

# Replace HoneyPi files with latest releases
echo '>>> Run HoneyPi Updater'
if [ $stable -eq 0 ] ; then
    # install pre-release
    sh update.sh 0
else
    # install stable
    sh update.sh
fi
echo '>>> All done. Please reboot your Pi :-)'
