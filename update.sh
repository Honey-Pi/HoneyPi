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
echo '>>> Install HoneyPi runtime measurement scripts'
rm -rf rpi-scripts # remove folder to download latest
if [ -d "rpi-scripts" ]; then
  echo 'Seems HoneyPi rpi-scripts is installed already, skip this step.'
else
  TAG=$(curl --silent "https://api.github.com/repos/Honey-Pi/rpi-scripts/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
  echo ">>> Downloading rpi-scripts $TAG"
  wget "https://github.com/Honey-Pi/rpi-scripts/archive/$TAG.zip" -O HoneyPiScripts.zip
  unzip HoneyPiScripts.zip
  mv $DIR/rpi-scripts-${TAG//v} $DIR/rpi-scripts
  sleep 1
  rm HoneyPiScripts.zip
fi

# install HoneyPi rpi-webinterface
echo '>>> Install HoneyPi webinterface'
rm -rf /var/www/html # remove folder to download latest
if [ -d "/var/www/html" ]; then
  echo 'Seems HoneyPi rpi-webinterface is installed already, skip this step.'
else
  TAG=$(curl --silent "https://api.github.com/repos/Honey-Pi/rpi-webinterface/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
  echo ">>> Downloading rpi-webinterface $TAG"
  wget "https://github.com/Honey-Pi/rpi-webinterface/archive/$TAG.zip" -O HoneyPiWebinterface.zip
  unzip HoneyPiWebinterface.zip
  mv $DIR/rpi-webinterface-${TAG//v}/dist /var/www/html
  mv $DIR/rpi-webinterface-${TAG//v}/backend /var/www/html/backend
  sleep 1
  rm -rf $DIR/rpi-webinterface-${TAG//v}
  rm HoneyPiWebinterface.zip

  # set file rights
  echo '>>> Set file rights to webinterface'
  chown -R www-data:www-data /var/www/html
  chmod -R 775 /var/www/html
fi