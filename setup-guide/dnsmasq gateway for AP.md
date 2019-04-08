## Specifying a default Gateway
`sudo nano /etc/dnsmasq.conf`

add

```
dhcp-option=3,192.168.4.1
```

then the file shood look like this:

```
interface=wlan0      # Use the require wireless interface - usually wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
dhcp-option=3,192.168.4.1
```