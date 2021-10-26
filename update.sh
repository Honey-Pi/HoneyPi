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

# decide to use stable release or pre-release [cmd for pre-releases: sh update.sh 0]
STABLE=${1:-1} # default: 1 (stable)

# Update CA certs for a secure connection to GitHub
echo '>>> Update CA certs for a secure connection'
wget https://curl.se/ca/cacert.pem -O /etc/ssl/certs/cacert.pem
update-ca-certificates --fresh

function get_latest_release() {
    REPO=$1
    STABLE=$2
    if [ $STABLE = 1 ]; then
        # return latest stable release
        result="$(curl --silent "https://api.github.com/repos/$REPO/releases/latest" -k | grep -Po '"tag_name": "\K.*?(?=")')"
    else
        # return lastest release, which can be also a pre-releases (alpha, beta, rc)
        result="$(curl --silent "https://api.github.com/repos/$REPO/tags" -k | grep -Po '"name": "\K.*?(?=")' | head -1)"
    fi
    echo "$result"
}

REPO="Honey-Pi/rpi-scripts"
ScriptsTag=$(get_latest_release $REPO $STABLE)
echo ">>> Install latest HoneyPi runtime measurement scripts ($ScriptsTag) from $REPO stable=$STABLE"
if [ ! -z "$ScriptsTag" ]; then
    [ -f $DIR/rpi-scripts/error.log ] && mv $DIR/rpi-scripts/error.log $DIR/error.log.backup
    CURRENTDATETIME=`date +%Y-%m-%d_%T`
    mv $DIR/rpi-scripts "$DIR/rpi-scripts-$CURRENTDATETIME"
    rm -rf $DIR/rpi-scripts # remove folder to download latest
    echo ">>> Downloading latest rpi-scripts ($ScriptsTag)"
    wget -q "https://codeload.github.com/$REPO/zip/$ScriptsTag" -O $DIR/HoneyPiScripts.zip
    unzip -q $DIR/HoneyPiScripts.zip -d $DIR
    mv $DIR/rpi-scripts-${ScriptsTag//v} $DIR/rpi-scripts
    [ -f $DIR/error.log.backup ] && mv $DIR/error.log.backup $DIR/rpi-scripts/error.log
    sleep 1
    rm $DIR/HoneyPiScripts.zip
    # set file rights
    echo '>>> Set file rights to python scripts'
    chown -R pi:pi $DIR/rpi-scripts
    chmod -R 775 $DIR/rpi-scripts
else
    echo '>>> Something went wrong. Updating rpi-scripts skiped.'
fi

REPO="Honey-Pi/rpi-webinterface"
WebinterfaceTag=$(get_latest_release $REPO $STABLE)
echo ">>> Install latest HoneyPi webinterface ($WebinterfaceTag) from $REPO stable=$STABLE"
if [ ! -z "$WebinterfaceTag" ]; then
    [ -f /var/www/html/backend/settings.json ] && mv /var/www/html/backend/settings.json $DIR/settings.json.backup
    rm -rf /var/www/html # remove folder to download latest
    echo ">>> Downloading latest rpi-webinterface ($WebinterfaceTag)"
    wget -q "https://codeload.github.com/$REPO/zip/$WebinterfaceTag" -O $DIR/HoneyPiWebinterface.zip
    unzip -q $DIR/HoneyPiWebinterface.zip -d $DIR
    mkdir -p /var/www
    mv $DIR/rpi-webinterface-${WebinterfaceTag//v}/dist /var/www/html
    mv $DIR/rpi-webinterface-${WebinterfaceTag//v}/backend /var/www/html/backend
    [ -f $DIR/settings.json.backup ] && mv $DIR/settings.json.backup /var/www/html/backend/settings.json
    touch /var/www/html/backend/settings.json # create empty file to give rights to
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
DATE=`date +%Y-%m-%d`
echo "HoneyPi (last install on Raspi: $DATE)" > /var/www/html/version.txt
echo "rpi-scripts $ScriptsTag" >> /var/www/html/version.txt
echo "rpi-webinterface $WebinterfaceTag" >> /var/www/html/version.txt

Postupgradescript=$"./rpi-scripts/$ScriptsTag/post-upgrade.sh"
echo ">>> checking for existance of post-upgrade script in: $Postupgradescript"
if [ -f "$Postupgradescript" ]; then
    echo '>>> Running post-upgrade script'
	$Postupgradescript
else
    echo '>>> No post-upgrade script for this Update.'
fi
