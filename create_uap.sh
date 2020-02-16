[ -z $BASH ] && { exec bash "$0" "$@" || exit; }
#!/bin/bash
# Create the virtual device
echo '>>> Create the virtual device uap0'
/sbin/iw dev wlan0 interface add uap0 type __ap
ip link set uap0 up
ip addr add 192.168.4.1/24 broadcast 192.168.4.255 dev uap0
ifup uap0
# Fetch wifi channel
CHANNEL=`iwlist wlan0 channel | grep Current | sed 's/.*Channel \([0-9]*\).*/\1/g'`
# if no network connected
if [[ -z "$CHANNEL" ]]; then
   echo "Info: Currently not connected to a network."
   CHANNEL="1"
fi
# prevent using 5Ghz (uap0: IEEE 802.11 Hardware does not support configured channel)
if [[ "$CHANNEL" -gt "13" ]]; then
   echo "Info: Select 5GHz (Channel: $CHANNEL) for AccessPoint"
   HWMODE="a" #5Ghz
else
   echo "Info: Select 2,4GHz (Channel: $CHANNEL) for AccessPoint"
   HWMODE="g" #2,4Ghz
fi
export CHANNEL && export HWMODE
# Create the config for hostapd
cat /etc/hostapd/hostapd.conf.tmpl | envsubst > /etc/hostapd/hostapd.conf
