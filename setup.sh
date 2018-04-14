#!/bin/bash
source setup.config

function help() {
  echo "\e[34mCreate a snips-ready rasbpian image"
  echo "Usage :"
  echo "-h              Get script usage"
  echo "-f              Force raspbian image download"
  echo "-d /dev/disk2   Select target disk"
}

# Get arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    help
    exit
    ;;
    -f|--force)
    FORCE=true
    shift # past argument
    shift # past value
    ;;
    -d|--disk)
    DISK="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Download the latest raspbian image
if [ ! -f ./raspbian-lite-latest.img ] || [ "$FORCE" = true ]; then
  echo "Downloading rasbpian image ..."
  wget downloads.raspberrypi.org/raspbian_lite_latest -O raspbian-lite-latest.zip
  echo "Unziping rasbpian image ..."
  unzip -p raspbian-lite-latest.zip > raspbian-lite-latest.img
  rm raspbian-lite-latest.zip
fi

# Burn the raspbian image
echo "Burning image ..."
dd bs=1m if=raspbian-lite-latest.img of="$DISK" conv=sync

# Add the boot options to the disk
diskutil mountDisk "$DISK"
if [ "$SSID" != "" ] && [ "$PSK" != "" ]; then
  cat > /Volumes/boot/wpa_supplicant.conf <<EOF
  ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
  update_config=1
  network={
      ssid="$SSID"
      psk="$PSK"
  }
EOF
fi
touch /Volumes/boot/ssh
echo "Your disk is ready !"