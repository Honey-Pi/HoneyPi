
* usb-modeswitch package damit ein usb-device automatisch als modem erkannt wird

```
sudo apt-get install usb-modeswitch
```
 
* ip-adresse bekommen, deshalb diese zwei Zeilen in `/etc/network/interfaces` einfügen
	
`sudo nano /etc/network/interfaces`

```
allow-hotplug wwan0
iface wwan0 inet dhcp
```
