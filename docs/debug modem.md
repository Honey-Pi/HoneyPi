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

	grep -a -B 2 -A 2 "usb_modeswitch\|modem\|pppd\|PPP\|ppp0\|ttyUSB0" /var/log/messages
	

