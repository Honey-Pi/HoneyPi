# Install

```
sudo apt-get install -y git
git clone --depth=1 https://github.com/Honey-Pi/HoneyPi.git HoneyPi
cd HoneyPi
sudo sh install.sh
```
> It is recommended to run it in your home directory.


# First start on a clean [Raspbian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/) OS

> We recommend flashing with [balenaEtcher](https://youtu.be/tcMT1hxhY3U)

1. Connect HDMI to a TV
2. Boot up
3. Login with username `pi` and password `raspberry`
4. Run `sudo rapi-config`
5. Select `5 Interfacing Options` and enable `P2 SSH`
6. Connect your Raspi Ethernet Bus to your Router. If you use a Raspi Zero you could configure a wifi network connection.
7. Now you can connect with your computer the first time via SSH to the Raspi.
8. Login again. Change password with `passwd` to `hivescale`
9. Run the Install Instructions from above
