## Physical install

### Mapping of WittyPi 2 & 3 Pins to Raspberry Pins

GPIO (BCM) | Name | Phycial PIN
--- | --- | ---:
2 | SDA | 3
3 | SCL | 5
4 | GPIO 7 | 7
17 | GPIO 0 | 11

- Double occupancy through BME680/BME280 (I2C: SDA&SCL) is no problem.

- The HoneyPi Button cannot be at GPIO17. Better would be GPIO16.

- 1-Wire default GPIO (used for DS18b20 sensors) must be switched to another GPIO (e.g. GPIO 11). It cannot stay at default value because GPIO4 is used from WittyPi.

- See p.37 in manual.pdf you can check the gpio states with `gpio readall`.


### Mapping of WittyPi 4 Pins to Raspberry Pins

I2C Address: 0x08

GPIO (BCM) | Name | Phycial PIN | Description
--- | --- | --- | ---:
2 | SDA 1 | 3 |
3 | SCL 1 | 5 |
4 | GPIO 7 | 7 |
17 | GPIO 0 | 11 |
14 | TXD | 8  |  high=system is on, low=system is off 

## Install WittyPi software on Raspbian

### [WittyPi 2](http://www.uugear.com/product/wittypi2/) and [WittyPi Mini](https://www.uugear.com/product/wittypi-mini/)

1. `cd ~`
2. `wget http://www.uugear.com/repo/WittyPi2/installWittyPi.sh`
3. `sudo sh installWittyPi.sh`
4. Skip -n fake-hwclock and Qt 5 GUI.
5. If Raspi 4 (Buster): Update WiringPi to the latest Raspbian Buster compatible version (>v2.52):
	- 	`wget https://project-downloads.drogon.net/wiringpi-latest.deb`
	- `sudo dpkg -i wiringpi-latest.deb`


### [WittyPi 3](http://www.uugear.com/product/witty-pi-3-realtime-clock-and-power-management-for-raspberry-pi/)

1. `cd ~`
2. `wget http://www.uugear.com/repo/WittyPi3/install.sh`
3. `sudo sh install.sh`


### [Witty Pi 4 Mini](https://www.uugear.com/product/witty-pi-4-mini/)


1. `cd ~`
2. `wget https://www.uugear.com/repo/WittyPi4/install.sh`
3. `sudo sh install.sh`


## Set schedule script
1. Save script as `schedule.wpi` to `/home/pi/wittyPi/schedule.wpi`
2. Run `cd /home/pi/wittyPi` and `sudo ./runScript.sh`


### Important files
`/etc/init.d/wittypi`
> should contain correct paths
