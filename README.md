# HoneyPi - smart DIY beehive scale
[![License](https://img.shields.io/badge/License-CC%20BY--NC--SA%203.0-blue.svg)](http://creativecommons.org/licenses/by-nc-sa/3.0/) [![YouTube Subscribe](https://img.shields.io/badge/youtube-subscribe-%23c4302b.svg)](https://www.youtube.com/channel/UCUkJqPlSRkmrHjoIF89-LHg) ![Twitter Follow](https://img.shields.io/twitter/follow/TheHoneyPi.svg?style=social&label=Follow)


HoneyPi is a measuring system based on the Raspberry Pi. Various [sensors](https://www.honey-pi.de/schaltplan-und-sensoren/) can be connected to the GPIO ports of the Raspberry Pi. It is a plug and play system. The configuration of the sensors and settings, such as the transfer interval, are made in the web interface on the Raspberry Pi. The data measured by the sensors are transmitted to the IoT platform ThingSpeak. From there they can be visualized in apps.

## Usage
### Install
> It is recommended to run it in your home directory.

```
sudo apt-get update && sudo apt-get dist-upgrade -y
sudo apt-get install -y git
cd ~
git clone --depth=1 https://github.com/Honey-Pi/HoneyPi.git HoneyPi
cd HoneyPi
sudo sh install.sh
```

### Quick start

Instead of installing you can simply download a ready HoneyPi image from our [download page](https://www.honey-pi.de/downloads/). You can even create your own custom HoneyPi images using our [HoneyPi image generator](https://github.com/Honey-Pi/HoneyPi-Build-Raspbian). These images are based on the latest Raspberry Pi OS Lite (previously known as raspbian lite) version.


### First start on a clean [Raspberry Pi OS Lite](https://www.raspberrypi.org/software/operating-systems/)

> We recommend flashing with [balenaEtcher](https://youtu.be/tcMT1hxhY3U)

1. Connect HDMI to a TV
2. Boot up
3. Login with username `pi` and password `raspberry`
4. Run `sudo raspi-config`
5. Select `5 Interfacing Options` and enable `P2 SSH`
6. Connect your Raspi Ethernet Bus to your Router. If you use a Raspi Zero you could configure a wifi network connection.
7. Now you can connect with your computer the first time via SSH to the Raspi.
8. Login again. Change password with `passwd` to `hivescale`
9. Run the Install Instructions from above
10. If you want to use a WittyPi module install it like explained [here](docs/WittyPi/).

## Development and Beta Testing
### Update to the latest release (also beta and pre-release)

```
cd /home/pi/HoneyPi/
# Update the Installer
sudo git pull
# Update the measurement scripts and the webinterface (Arg1 to select stable or pre-release,  for stable use 1 for betatest use 0)
sudo sh update.sh 0
```

## Start and Stop HoneyPi Service

In previous versions (before v1.3.7) the measurement scripts have been autostarted after the booting of the Raspberry Pi (we used `/etc/rc.local`). There was no option to start/stop the measurement service. Only by pressing the hardware button the measurement routine stopped. But now we changed this behaviour. If you are connected by terminal you can start and stop the honeypi service on your Raspberry Pi. Don't forget to enable the service after you stopped for your next reboot. Also you can use the [webinterface backend](https://github.com/Honey-Pi/rpi-webinterface#backend) to remotely control your Raspberry Pi. 

```
# check status
sudo systemctl status honeypi.service
# stop service (e.g. for manually testing)
sudo systemctl stop honeypi.service
# start service (if stopped before)
sudo systemctl start honeypi.service
# debug, see all error messages related to the service
sudo journalctl --unit=honeypi
# reload if crashed before
sudo systemctl reload-or-restart honeypi
```
