## usb_modeswitch Debugging Cheatsheet

show all network interfaces

	ifconfig -a
	
show all usb devices

	lsusb
	
check if attaching usb worked

	dmesg|grep USB
	
set HUAWEI usb surfstick to modem	
	
	usb_modeswitch -v 0x12d1 -p 0x1f01 -M "55534243123456780000000000000011062000000100000000000000000000"
	
Run a rule manually
 
 	usb_modeswitch -c /etc/usb_modeswitch.d/12d1:1f01
 	
check if switching to modem worked

	dmesg | grep ttyUSB
	
list all serial ports

	ls -la /dev/ttyUSB*
	
* ```14dc``` is the device-id before it has been switched to modem (depending on modell and firmware)
* ```1001``` is the devide-id as modem

switching to storage mode

	usb_modeswitch -v 12d1 -p 1f01 -V 12d1 -P 14DC -J
		
check /var/log/messages

	grep -a -B 2 -A 2 "usb_modeswitch\|modem\|pppd\|PPP\|ppp0\|ttyUSB0\|wvdial" /var/log/messages
	

### Check if internet with surfstick does work
disable internet but do not disconnect wlan0

	sudo ip route del default via 192.168.178.0 dev wlan0
		
enable internet again

	sudo ip route add default via 192.168.178.0 dev wlan0
	
check with which ip address raspi goes outside

	wget --server-response -q -S -O - bot.whatismyipaddress.com
	
	whois IPv6: https://www.ultratools.com/tools/ipv6InfoResult?ipAddress=2001%3A16b8%3A2489%3A9500%3Aba27%3Aebff%3Afe95%3Aa3d1
	whois ipv4: https://www.ultratools.com/tools/ipWhoisLookupResult
	
show rounting table and gateways

	netstat -rn
	
use ppp0 instead of wlan0

	ip route show
	# delete default route
	sudo ip route del default 
	# connect to wlan0 route
	sudo route add default gw 192.168.178.78
	# connect to ppp0 route
	sudo route add default gw 10.64.64.64
	sudo ip route add default via 10.189.96.198 dev ppp0	