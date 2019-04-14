## Physical install
### WittyPi Pins to Raspberry Pins

GPIO (BCM) | Name | Phycial PIN
--- | --- | ---:
2 | SDA | 3
3 | SCL | 5
4 | GPIO4 | 7
17 | GPIO17 | 11

> double occupancy through BME680 (SDA&SCL) and Button at GPIO17.
> 1-Wire default GPIO must be switched to another GPIO (e.g. )
> See p.37 in manual.pdf you can check the gpio states with `gpio readall`.

## Install WittyPi on Raspbian

1. `wget http://www.uugear.com/repo/WittyPi2/installWittyPi.sh`

2. `sudo sh installWittyPi.sh`

3. Skip -n fake-hwclock and Qt 5 GUI.

## Set schedule script
1. Save script as `schedule.wpi` to `/home/pi/wittyPi/schedule.wpi`
2. Run `cd /home/pi/wittyPi` and `sudo ./runScript.sh`


### Important files
`/etc/init.d/wittypi`
> should contain correct paths
