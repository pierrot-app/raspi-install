#!/user/bin/env bash

source wifi.config

# If "-h" or "--help" is set, echo the usage of this script
# If "-f" or "--force" is set, force download the latest raspbian image
# "-d" or "--disk" is the disk identifier required to burn the image to the disk

# Set an initial value for the parameters
HELP=false
DL=false

function usage() {
  echo ""
  echo "$(tput bold)Create a snips-ready rasbpian image$(tput sgr0)"
  echo "Usage :"
  echo "-h              Get script usage"
  echo "-f              Force raspbian image download"
  echo "-d /dev/disk2   Select target disk"
}

function getImage() {
  echo ""
  echo "Downloading rasbpian image ..."
  wget -q downloads.raspberrypi.org/raspbian_lite_latest -O raspbian-lite-latest.zip
  echo ""
  echo "Unziping rasbpian image ..."
  unzip -p raspbian-lite-latest.zip > raspbian-lite-latest.img
  rm raspbian-lite-latest.zip
}

function setWpa() {
  cat > /Volumes/boot/wpa_supplicant.conf <<EOF
  ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
  update_config=1
  country=$COUNTRY

  network={
      ssid="$SSID"
      psk="$PSK"
  }
EOF
}

function setSSH() {
  touch /Volumes/boot/ssh
}

function unmount() {
  sudo diskutil unmountDisk force $DISK
}

function mount() {
  diskutil mountDisk $DISK
}

# Extract options and their arguments into variables.
while getopts "hfd:" flag
do
  case $flag in
    h) HELP=true ; shift ;;
    f) DL=true ; shift ;;
    d) DISK=$OPTARG ; shift ;;
  esac
done

echo $DL

# Check if user is root
if [ $EUID -ne 0 ]; then
  echo ""
  echo "This tool must be run as root"
  exit 1
fi

# Echo usage if asked
if [ $HELP = true ]; then
  usage
  exit 0;
fi

# Check if image has already been downloaded
for i in ./raspbian-lite-latest.*; do
  if [ ! -e $i ]; then
    DL=1
  fi
done

# Download the latest raspbian image
if [ $DL = true ]; then
  getImage
else
  echo ""
  echo "Image download skipped"
fi

# Ask target directory
if [ -z $DISK ]; then
  echo ""
  echo "You need to specify a disk to continue"
  echo "Check the usage runnning $(tput bold)setup.sh -h$(tput sgr0)"
  echo ""
  echo "Specify the target disk $(tput bold)(eg. /dev/disk2)$(tput sgr0)"
  read -p "" DISK
  echo ""
fi

# Burn the raspbian image
echo ""
unmount
echo "Burning the image ..."
dd bs=1m if=raspbian-lite-latest.img of=$DISK conv=sync

# Remount the disk
unmount
mount

# Add SSH & wifi config files
setWpa
setSSH

echo "All done !"
exit 0;