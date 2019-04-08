> Anleitung: https://www.elektronik-kompendium.de/sites/raspberry-pi/1905271.htm


* Vor der Installation kann man noch die Paketdatenbank aktualisieren und ein Upgrade vornehmen:

```
sudo apt-get update
sudo apt-get upgrade
```

* Anschließend installiert man den lighttpd-Server:

```
sudo apt-get install lighttpd
```

* Nach der Installation wird der HTTP-Daemon in der Regel automatisch gestartet. Ob das funktioniert hat, kann man mit folgenden Befehl prüfen:

```
sudo systemctl status lighttpd
```

* Anschließend öffnen wir einen Webbrowser und den Hostnamen des Raspberry Pi in die Adresszeile ein. Wenn alles rund gelaufen ist, erscheint die Standard-Seite des Lighttpd-Servers ("Placeholder page").

http://raspberrypi.local/

* Das Webserver-Verzeichnis befindet sich bei Raspbian Weezy unter `/var/www` und bei Raspbian Jessie unter `/var/www/html`. Diese Standard-Einstellungen kann man natürlich später noch ändern. Vorerst belassen wir das so. In diesen Verzeichnissen legen wir später die HTML-Dateien ab.

* Bevor man nun Dateien ins Webserver-Verzeichnis legen kann, sollte man nacheinander noch ein paar Rechte setzen.

```
sudo groupadd www-data
sudo usermod -G www-data -a pi
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 775 /var/www/html
```

* Nun noch einmal lighttpd neustarten:

```
sudo service lighttpd force-reload
```

* PHP lauffähig machen

```sudo apt-get install php7.0-cgi```

* enable fastcgi modules

```sudo lighttpd-enable-mod fastcgi fastcgi-php```

* Nun noch einmal lighttpd neustarten:

```sudo service lighttpd force-reload```