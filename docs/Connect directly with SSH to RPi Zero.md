## Connect Raspberry Zero directly with USB to MacBook

### Mac Catalina:

1. install [RNDIS](https://github.com/jwise/HoRNDIS/issues/102#issuecomment-541237232) to your Mac

2. reboot Mac

2. follow this [instruction](https://raspberrypi.stackexchange.com/a/64514) to setup RNDIS
	
	
3. follow one of these instructions ([1](https://www.thepolyglotdeveloper.com/2016/06/connect-raspberry-pi-zero-usb-cable-ssh/) / [2](https://desertbot.io/blog/ssh-into-pi-zero-over-usb)) on raspberry zero	

If RNDIS on Mac is still not detecting the usb plug, setup the following on the Raspberry:

	sudo nano /etc/network/interfaces
	```
	allow-hotplug usb0
	iface usb0 inet dhcp
	```
	
	# refresh	
	sudo systemctl daemon-reload
	
	# restart networking
	sudo /etc/init.d/networking restart
	# start usb0
	sudo ifdown usb0 && sudo ifup usb0 && ifconfig usb0

	
check for errors

	systemctl status networking.service
	journalctl -xe
	systemctl status dhcpcd.service 
	
	
run after changes on dhcpcd file
	
	sudo systemctl daemon-reload
	
	
check dhcpcd.service errors

	systemctl status dhcpcd.service 