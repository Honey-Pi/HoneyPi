[ -z $BASH ] && { exec bash "$0" "$@" || exit; }
#!/bin/bash
# file: update.sh
#
# This script will install required software for HoneyPi.
# It is recommended to run it in your home directory.
#

# check if sudo is used
if [ "$(id -u)" != 0 ]; then
    echo 'Sorry, you need to run this script with sudo'
    exit 1
fi

# target directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# install HoneyPi rpi-scripts
echo '>>> Install latest HoneyPi runtime measurement scripts (non-prerelease and non-draft)'
ScriptsTag=$(curl --silent "https://api.github.com/repos/Honey-Pi/rpi-scripts/releases/latest" -k | grep -Po '"tag_name": "\K.*?(?=")')
if [ $ScriptsTag ]; then
    rm -rf $DIR/rpi-scripts # remove folder to download latest
    echo ">>> Downloading latest rpi-scripts ($ScriptsTag)"
    wget -q --show-progress "https://codeload.github.com/Honey-Pi/rpi-scripts/zip/$ScriptsTag" -O $DIR/HoneyPiScripts.zip
    unzip $DIR/HoneyPiScripts.zip -d $DIR -q
    mv $DIR/rpi-scripts-${ScriptsTag//v} $DIR/rpi-scripts
    sleep 1
    rm $DIR/HoneyPiScripts.zip
    # set file rights
    echo '>>> Set file rights to python scripts'
    chown -R pi:pi $DIR/rpi-scripts
    chmod -R 775 $DIR/rpi-scripts
else
    echo '>>> Something went wrong. Updating rpi-scripts skiped.'
fi

# install HoneyPi rpi-webinterface
echo '>>> Install latest HoneyPi webinterface (non-prerelease and non-draft)'
WebinterfaceTag=$(curl --silent "https://api.github.com/repos/Honey-Pi/rpi-webinterface/releases/latest" -k | grep -Po '"tag_name": "\K.*?(?=")')
if [ $WebinterfaceTag ]; then
    [ -f /var/www/htm/backend/settings.json ] && mv /var/www/htm/backend/settings.json $DIR/settings.json.backup
    rm -rf /var/www/html # remove folder to download latest
    echo ">>> Downloading latest rpi-webinterface ($WebinterfaceTag)"
    wget -q --show-progress "https://codeload.github.com/Honey-Pi/rpi-webinterface/zip/$WebinterfaceTag" -O $DIR/HoneyPiWebinterface.zip
    unzip $DIR/HoneyPiWebinterface.zip -d $DIR -q
    mkdir -p /var/www
    mv $DIR/rpi-webinterface-${WebinterfaceTag//v}/dist /var/www/html
    mv $DIR/rpi-webinterface-${WebinterfaceTag//v}/backend /var/www/html/backend
    [ -f $DIR/settings.json.backup ] && mv $DIR/settings.json.backup /var/www/htm/backend/settings.json
    sleep 1
    rm -rf $DIR/rpi-webinterface-${WebinterfaceTag//v}
    rm $DIR/HoneyPiWebinterface.zip
    # set file rights
    echo '>>> Set file rights to webinterface'
    chown -R www-data:www-data /var/www/html
    chmod -R 775 /var/www/html
else
    echo '>>> Something went wrong. Updating rpi-webinterface skiped.'
fi

# Create File with version information
DATE=`date +%d-%m-%y`
echo "HoneyPi (last install on RPi: $DATE)" > /var/www/html/version.txt
echo "rpi-scripts $ScriptsTag" >> /var/www/html/version.txt
echo "rpi-webinterface $WebinterfaceTag" >> /var/www/html/version.txt
