* stoppe services von AccessPoint

```
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
```

* `sudo nano /etc/wpa_supplicant/wpa_supplicant.conf`

```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
 
network={
ssid="wifi"
scan_ssid=1
#proto=RSN
#key_mgmt=WPA-PSK
pairwise=CCMP
#group=TKIP
psk="password"
}
```

### Alle Befehle ab hier sind nicht notwendig zu Einrichtung

* Bevor nun der wpa_supplicant fest eingebunden wird, sollte er getestet werden. Dies kann über die Debugging-Funktion geschehen, indem man Folgendes in ein Terminal [3] eingibt:

```
sudo wpa_supplicant -i wlan0 -D wext -c /etc/wpa_supplicant/wpa_supplicant.conf -d 
```

* Starte WPA Daemon

```
sudo wpa_supplicant -i wlan0 -D wext -c /etc/wpa_supplicant/wpa_supplicant.conf -B 
```

* Als letztes ist noch der DHCP-Client für das Wireless Interface zu starten (damit man eine IP-Adresse bekommt):

```
sudo dhclient wlan0
```

* Starte AccessPoint

```
sudo systemctl stop wpa_supplicant && sudo systemctl start hostapd && sudo systemctl start dnsmasq
sudo systemctl start hostapd
sudo systemctl start dnsmasq
```

* Stoppe Wifi

```
wpa_cli -p /var/run/wpa_supplicant terminate
```