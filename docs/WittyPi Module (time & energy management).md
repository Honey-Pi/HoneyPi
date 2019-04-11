## Physical install 
### WittyPi Pins to Raspberry Pins

GPIO (BCM) | Name | Phycial PIN 
--- | --- | ---: 
2 | SDA | 3
3 | SCL | 5
4 | GPIO4 | 7
17 | GPIO17 | 11

> double occupancy through BME680 (SDA&SCL) and Button at GPIO17.

## Install WittyPi on Raspbian

1. `wget http://www.uugear.com/repo/WittyPi2/installWittyPi.sh`

2. `sudo sh installWittyPi.sh`

## Set schedule script
1. Save script as `schedule.wpi` to `home\pi\wittyPi\schedule.wpi`
2. Run `sh home\pi\wittyPi\runScript.sh`

