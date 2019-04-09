* settings.php und log.php benötigen noch entsprechende Rechte:

```
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 775 /var/www/html
```

* Von PHP ausgeführten Shell Befehlen noch die Rechte geben
sudo visudo
* diese Zeilen hinzufügen:

```
#HoneyPi
www-data ALL = NOPASSWD: /sbin/reboot, /sbin/halt
www-data ALL = NOPASSWD: /var/www/html/backend/shell-scripts/*.sh
www-data ALL = NOPASSWD: /var/www/html/backend/shell-scripts/clear_log.sh
www-data ALL = NOPASSWD: /var/www/html/backend/shell-scripts/change_router_pw.sh
www-data ALL = NOPASSWD: /var/www/html/backend/shell-scripts/change_router_ssid.sh
www-data ALL = NOPASSWD: /var/www/html/backend/shell-scripts/change_honeypi_ssidpw.sh

#network interfaces
www-data ALL = NOPASSWD: /bin/sed * /etc/wpa_supplicant/wpa_supplicant.conf;

#hostapd.conf file
www-data ALL = NOPASSWD: /bin/sed * /etc/hostapd/hostapd.conf;
```

* ACHTUNG (nur fürs debuggen) Alle Befehle erlauben:

```
www-data ALL=NOPASSWD: ALL
```