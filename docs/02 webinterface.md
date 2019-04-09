	lighttpd/webserver
		Das Webserver-Verzeichnis befindet sich bei Raspbian Weezy unter "/var/www" und bei Raspbian Jessie unter "/var/www/html".
		Die Webinterface Dateien, die in das /var/www/html/ Verzeichnis sollen, befinden sich hier:
			https://github.com/Honey-Pi/rpi-webinterface/tree/master/dist
		Außerdem muss dieser Backend-ordner in das /var/www/html/backend/ Verzeichnis:
			https://github.com/Honey-Pi/rpi-webinterface/tree/master/backend
		Diese Rechte sind für die Dateien notwendig:
			Der "backend" Ordner bekommt mit allen Unterdateien chmod 775