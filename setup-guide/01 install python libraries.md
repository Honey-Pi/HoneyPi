# Für die .py Skripte war noch notwendig:
```
sudo apt-get install rpi.gpio
sudo apt-get install python-numpy
sudo apt-get install python-smbus
```

# pip für python 2 hat gefehlt:
```
sudo apt-get install python-setuptools
sudo easy_install pip
```

# um thingspeak über pip zu installieren:
```
sudo pip install thingspeak
```

# um den BME680-Sensor zu verwenden:
```
sudo pip install bme680
```

# pathlib ist nur in python3 standardgemäß dabei und muss daher für python2 nachinstalliert werden:
```
sudo pip install pathlib
```