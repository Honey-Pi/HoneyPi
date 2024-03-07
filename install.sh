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
echo '>>> Enable I2C'
if grep -q 'i2c-bcm2708' /etc/modules; then
  echo 'Seems i2c-bcm2708 module already exists, skip this step.'
else
  echo 'i2c-bcm2708' >> /etc/modules
fi
if grep -q '^i2c-dev' /etc/modules; then
  echo 'Seems i2c-dev module already exists, skip this step.'
else
  echo 'i2c-dev' >> /etc/modules
fi
if grep -q 'dtparam=i2c1=on' /boot/config.txt; then
  echo 'Seems i2c1 parameter already set, skip this step.'
else
  echo 'dtparam=i2c1=on' >> /boot/config.txt
fi
if grep -q '^dtparam=i2c_arm=on' /boot/config.txt; then
  echo 'Seems i2c_arm parameter already set, skip this step.'
else
  echo 'dtparam=i2c_arm=on' >> /boot/config.txt
fi

# enable 1-Wire on Raspberry Pi
echo '>>> Enable 1-Wire'
if grep -q '^w1_gpio' /etc/modules; then
  echo 'Seems w1_gpio module already exists, skip this step.'
else
  echo 'w1_gpio' >> /etc/modules
fi
if grep -q '^w1_therm' /etc/modules; then
  echo 'Seems w1_therm module already exists, skip this step.'
else
  echo 'w1_therm' >> /etc/modules
fi
if grep -q '^dtoverlay=w1-gpio' /boot/config.txt; then
  echo 'Seems w1-gpio parameter already set, skip this step.'
else
  echo 'dtoverlay=w1-gpio,gpiopin='$w1gpio >> /boot/config.txt
fi

# enable miniuart-bt on Raspberry Pi and set core frequency, for stable miniUART and bluetooth (see https://www.raspberrypi.org/documentation/configuration/uart.md)
echo "Install required miniuart-bt modules for rak811 & WittyPi..."
if grep -q 'dtoverlay=pi3-miniuart-bt' /boot/config.txt; then
  echo 'Seems setting Pi3/4 Bluetooth to use mini-UART is done already, skip this step.'
else
  echo 'dtoverlay=pi3-miniuart-bt' >> /boot/config.txt
fi
if grep -q 'core_freq=250' /boot/config.txt; then
  echo 'Seems the frequency of GPU processor core is set to 250MHz already, skip this step.'
else
  echo 'core_freq=250' >> /boot/config.txt
fi

# Enable HDMI for a default "safe" mode to work on all screens
if grep -q '#hdmi_safe=1' /boot/config.txt; then
  sed -i 's/#hdmi_safe=1/hdmi_safe=1/' /boot/config.txt
else
  if grep -q 'hdmi_safe=1' /boot/config.txt; then
	echo 'Seems the hdmi is set to safe mode already, skip this step.'
  else
	echo 'hdmi_safe=1' >> /boot/config.txt
  fi
fi

echo '>>> Enable Wifi'
rfkill unblock all

# Enable Wifi-Stick on Raspberry Pi 1 & 2
if grep -q 'net.ifnames=0' /boot/cmdline.txt; then
    echo 'Seems net.ifnames=0 parameter already set, skip this step.'
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
apt-get -y install --no-install-recommends ntp
dpkg-reconfigure -f noninteractive ntp

echo '>>> Apply a ntpd config'
cp overlays/ntp.conf /etc/ntpsec/ntp.conf

echo '>>> Apply Fix for "statistics directory /var/log/ntpsec/ does not exist or is unwriteable, error No such file or directory" message'
mkdir /var/log/ntpsec/
chown -R ntpsec:ntpsec /var/log/ntpsec/

# rpi-scripts
echo '>>> Install NumPy for measurement python scripts'
apt-get -y install --no-install-recommends python3-numpy
echo '>>> Install apt-get packages for measurement python scripts'
apt-get -y install --no-install-recommends python3-rpi.gpio python3-smbus libatlas3-base python3-setuptools python3-pip libatlas-base-dev libgpiod2
echo '>>> Set pip to --break-system-packages true because we dont want to use pip-venv or pipx' # because of --break-system-packages issue: https://askubuntu.com/q/1465218
python3 -m pip config set global.break-system-packages true
mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old
export PIP_ROOT_USER_ACTION=ignore
echo '>>> Upgrade pip to at least v22.3'
python3 -m pip install --upgrade pip # upgrade pip to at least v22.3
echo '>>> Install pip3 libraries for measurement python scripts'
pip3 install -r requirements.txt --upgrade
echo '>>> Install deprecated DHT library for measurement python scripts (still used for read_dht_zero.py)'
# deprecated, but still used for Pi Zero WH because of known issues such as https://github.com/adafruit/Adafruit_CircuitPython_DHT/issues/73 - no longer working on bullseye
python3 -m pip install --upgrade pip setuptools wheel # see: https://stackoverflow.com/a/72934737/6696623
pip3 install Adafruit_DHT
pip3 install Adafruit_Python_DHT

echo '>>> Uninstall old numpy pip package - v1.4'
pip3 uninstall --yes numpy
apt-get -y remove python3-numpy
echo '>>> Install pip3 timezonefinder and numpy - v1.3.7 - PA1010D (gps)'
apt-get -y install --no-install-recommends libopenblas-dev
pip3 install timezonefinder==6.1.8 # required since version v1.3.7 - PA1010D (gps)
pip3 install numpy # Required for ds18b20

# required since version v1.3.7
echo '>>> Install software for v1.3.7 - packages used for oled display and python3-psutil is used to kill processes'
apt-get -y install --no-install-recommends libopenjp2-7 libtiff5 python3-psutil

# rpi-webinterface
echo '>>> Install software for Webinterface'
apt-get -y install --no-install-recommends lighttpd php-cgi
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
apt-get -y install --no-install-recommends wvdial usb-modeswitch usb-modeswitch-data
cp overlays/wvdial.conf /etc/wvdial.conf
cp overlays/wvdial.conf.tmpl /etc/wvdial.conf.tmpl
chmod 755 /etc/wvdial.conf
cp overlays/wvdial /etc/ppp/peers/wvdial

echo '>>> Place a motd welcome screen'
cp overlays/motd /etc/motd



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

echo '>>> Enable rc.local'
chmod +x /etc/rc.local
systemctl enable rc-local.service

echo '>>> Enable HoneyPi Service as autostart'
sed -i '/(sleep 2;python3/c\#' /etc/rc.local # disable autostart in rc.local
cp overlays/honeypi.service /lib/systemd/system/honeypi.service
chmod 644 /lib/systemd/system/honeypi.service
systemctl daemon-reload
systemctl enable honeypi.service

# AccessPoint
echo '>>> Set Up Raspberry Pi as Access Point'
apt-get -y install --no-install-recommends dnsmasq hostapd
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

# set folder permissions, somehow this line was necessary since Raspi OS bookworm
echo '>>> Set file rights to /home/pi folder'
chown -R pi:pi /home/pi
chmod -R 755 /home/pi

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
