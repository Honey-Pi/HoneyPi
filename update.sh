#!/bin/bash

[ -z $BASH ] && { exec bash "$0" "$@" || exit; }

# file: update.sh
# This script will install required software for HoneyPi.
# It is recommended to run it in your home directory.

# Ensure the script is run as root
if [ "$(id -u)" != 0 ]; then
    echo 'Sorry, you need to run this script with sudo'
    exit 1
fi

# Target directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Decide to use stable release or pre-release [cmd for pre-releases: sh update.sh 0]
STABLE=${1:-1} # default: 1 (stable)

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/honeypi_update.log
}

# Function to update CA certificates
update_ca_certificates() {
    log 'Download cacert.pem from curl.se and place it in /usr/share/ca-certificates/local/'
    mkdir -p /usr/share/ca-certificates/local
    wget -q https://curl.se/ca/cacert.pem -O /usr/share/ca-certificates/local/ca-certificates.crt
    log 'Update CA certs for a secure connection'
    update-ca-certificates --fresh
}

# Function to get the latest release from a GitHub repository
get_latest_release() {
  local repo=$1
  local stable=$2
  if [ "$stable" -eq 1 ]; then
      # return latest stable release
      result="$(curl --silent "https://api.github.com/repos/$repo/releases/latest" -k | grep -Po '"tag_name": "\K.*?(?=")')"
  else
      # return lastest release, which can be also a pre-releases (alpha, beta, rc)
      result="$(curl --silent "https://api.github.com/repos/$repo/tags" -k | grep -Po '"name": "\K.*?(?=")' | head -1)"
  fi
  echo "$result"
}

# Function to download and install scripts
install_scripts() {
    local repo=$1
    local tag=$2
    log "Installing latest HoneyPi runtime measurement scripts ($tag) from $repo"
    if [ -n "$tag" ]; then
        if [ ! -d "$DIR/rpi-scripts" ]; then
            log "rpi-scripts does not exist, propably first fresh install."
        else
            [ -f "$DIR/rpi-scripts/error.log" ] && mv "$DIR/rpi-scripts/error.log" "$DIR/error.log.backup"
            #local current_datetime=$(date +%Y-%m-%d_%T)
            #mv "$DIR/rpi-scripts" "$DIR/rpi-scripts-$current_datetime"
            rm -rf "$DIR/rpi-scripts" # remove folder to download latest
        fi
        log "Downloading latest rpi-scripts ($tag)"
        wget -q "https://codeload.github.com/$repo/zip/$tag" -O "$DIR/HoneyPiScripts.zip"
        unzip -q -o "$DIR/HoneyPiScripts.zip" -d "$DIR"
        mv "$DIR/rpi-scripts-${tag//v}" "$DIR/rpi-scripts"
        [ -f "$DIR/error.log.backup" ] && mv "$DIR/error.log.backup" "$DIR/rpi-scripts/error.log"
        rm "$DIR/HoneyPiScripts.zip"
        # Set file rights
        log 'Set file rights to python scripts'
        chown -R pi:pi "$DIR/rpi-scripts"
        chmod -R 775 "$DIR/rpi-scripts"
    else
        log 'Something went wrong. Updating rpi-scripts skipped.'
    fi
}

# Function to download and install web interface
install_webinterface() {
    local repo=$1
    local tag=$2
    log "Installing latest HoneyPi webinterface ($tag) from $repo"
    if [ -n "$tag" ]; then
        [ -f /var/www/html/backend/settings.json ] && mv /var/www/html/backend/settings.json "$DIR/settings.json.backup"
        rm -rf /var/www/html # remove folder to download latest
        log "Downloading latest rpi-webinterface ($tag)"
        wget -q "https://codeload.github.com/$repo/zip/$tag" -O "$DIR/HoneyPiWebinterface.zip"
        unzip -q -o "$DIR/HoneyPiWebinterface.zip" -d "$DIR"
        mkdir -p /var/www
        mv "$DIR/rpi-webinterface-${tag//v}/dist" /var/www/html
        mv "$DIR/rpi-webinterface-${tag//v}/backend" /var/www/html/backend
        [ -f "$DIR/settings.json.backup" ] && mv "$DIR/settings.json.backup" /var/www/html/backend/settings.json
        touch /var/www/html/backend/settings.json # create empty file to give rights to
        rm -rf "$DIR/rpi-webinterface-${tag//v}"
        rm "$DIR/HoneyPiWebinterface.zip"
        # Set file rights
        log 'Set file rights to webinterface'
        chown -R www-data:www-data /var/www/html
        chmod -R 775 /var/www/html
    else
        log 'Something went wrong. Updating rpi-webinterface skipped.'
    fi
}

# Function to create version information file
create_version_info() {
    local scripts_tag=$1
    local webinterface_tag=$2
    local date=$(date +%Y-%m-%d)
    log 'Creating version information file'
    echo "HoneyPi (last install on Raspi: $date)" > /var/www/html/version.txt
    echo "rpi-scripts $scripts_tag" >> /var/www/html/version.txt
    echo "rpi-webinterface $webinterface_tag" >> /var/www/html/version.txt
}

# Function to run post-upgrade script if exists
run_post_upgrade_script() {
    local scripts_tag=$1
    local postupgradescript="$DIR/rpi-scripts/post-upgrade/post-upgrade.sh"
    log "Checking for existence of post-upgrade script in: $postupgradescript"
    if [ ! -f "$postupgradescript" ]; then
        postupgradescript="$DIR/rpi-scripts/$scripts_tag/post-upgrade.sh"
    fi

    if [ -f "$postupgradescript" ]; then
        log 'Running post-upgrade script'
        "$postupgradescript"
    else
        log 'No post-upgrade script for this update.'
    fi
}

# Main execution
update_ca_certificates

REPO="Honey-Pi/rpi-scripts"
ScriptsTag=$(get_latest_release $REPO $STABLE)
install_scripts $REPO $ScriptsTag

REPO="Honey-Pi/rpi-webinterface"
WebinterfaceTag=$(get_latest_release $REPO $STABLE)
install_webinterface $REPO $WebinterfaceTag

create_version_info $ScriptsTag $WebinterfaceTag
run_post_upgrade_script $ScriptsTag

log 'Update completed successfully'
