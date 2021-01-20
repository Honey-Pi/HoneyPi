## debug wpa_supplicant

restart wpa_supplicant

	sudo killall wpa_supplicant
	sudo wpa_supplicant -c/etc/wpa_supplicant/wpa_supplicant.conf -iwlan0
	
	
list avaiable interfaces

	iw dev

list conntected channels

	iwlist wlan0 channel