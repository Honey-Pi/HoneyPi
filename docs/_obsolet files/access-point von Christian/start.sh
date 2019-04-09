#!/bin/bash
# Disable Network Manager wireless

export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
dbus-send --system --print-reply --dest=org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.DBus.Properties.Set string:"org.freedesktop.NetworkManager" string:"WirelessEnabled" variant:boolean:false

# Do some cleaning up
pkill -9 dnsmasq
rfkill unblock wlan
ifdown wlan0
ifup wlan0

# Start the access point
hostapd /etc/hostapd/hostapd.conf &
dnsmasq --keep-in-foreground



#sudo shutdown -h 7
cd /home/pi/real-beans-master/ 
source .venv/bin/activate 
python3 manage.py runserver 0.0.0.0:8001 

