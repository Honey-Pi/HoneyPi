# Setup for sensors
## [BME680](https://learn.pimoroni.com/tutorial/sandyj/getting-started-with-bme680-breakout)

	# dieses package hatte bei mir bei raspbian-lite gefehlt:
	sudo apt-get install python-smbus
	
	# You'll need to have I2C enabled:
	curl https://get.pimoroni.com/i2c | bash
	# I2C war bei mir nach einem Neustart auf einmal wieder deaktiviert https://developer-blog.net/raspberry-pi-i2c-aktivieren/
	
	# Next, in the terminal, type the following to clone the repository and install it
	git clone https://github.com/pimoroni/bme680
	cd bme680/library
	sudo python setup.py install
	
	# To run the example, type the following
	cd /home/pi/bme680/examples
	python read-all.py
	
## [1Wire/DS18b20](https://tutorials-raspberrypi.de/raspberry-pi-temperatur-mittels-sensor-messen/)
	
	# Wenn alles entsprechend verkabelt ist, können wir das 1-Wire Protokoll damit aktivieren:
	sudo modprobe w1-gpio
	sudo modprobe w1-therm
	
## [HX711](https://tutorials-raspberrypi.de/raspberry-pi-waage-bauen-gewichtssensor-hx711/)

	# dieses package hatte bei mir auf raspbian-lite gefehlt:
	sudo apt-get install python-numpy
	sudo apt-get install python-rpi.gpio
	
	git clone https://github.com/tatobari/hx711py
	
## [DHT11/DHT22](http://www.circuitbasics.com/how-to-set-up-the-dht11-humidity-sensor-on-the-raspberry-pi/)
	git clone https://github.com/adafruit/Adafruit_Python_DHT.git
	cd Adafruit_Python_DHT
	sudo apt-get install build-essential python-dev
	sudo python setup.py install