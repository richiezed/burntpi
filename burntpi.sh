#! /bin/bash
## USAGE ./image.sh
## Configuration is read from image.yaml in the same directory

## Standard paths to image files
## TODO: Somehow get these dynmaically, otherwise requires an update for each new Raspberry Pi OS release

LITE_PATH="https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip"
STANDARD_PATH="https://downloads.raspberrypi.org/raspios_armhf/images/raspios_armhf-2021-05-28/2021-05-07-raspios-buster-armhf.zip"
FULL_PATH="https://downloads.raspberrypi.org/raspios_full_armhf/images/raspios_full_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-full.zip"

set -e

# Load the configuration
. ./readconfig.sh
eval $(parse_yaml image.yaml "config_")

# Check some basic config items
# These are the only config item that are checked by the main script
# All others are the responsibility of the modules

# Confirm that the image has been configured correctly

if [ -z "$config_image" ] ; then
    echo "Need to set image type. USAGE: image: [ lite | standard | full ]"
    exit 1
fi

image_types=(lite standard full)

case $config_image in
    lite ) RASPOS_PATH=$LITE_PATH;;
    standard ) RASPOS_PATH=$STANDARD_PATH;;
    full ) RASPOS_PATH=$FULL_PATH;;
    * ) echo "Incorrect image type. USAGE: image: [ lite | standard | full ]"; exit;;
esac

# Confirm that the timezone has been configured correctly

if [ -z "$config_module_timezone" ] ; then
    echo "Need to set Timezone environment variable"
    exit 1
fi

# Source the script which checks the which drive to write to

. sddevice.sh

# Download the image if it doesn't exist

if [ -z "$RASPOS_PATH" ] ; then
    echo "Error selecting image"
    exit 1
fi

RASPOS_FILE=`basename $RASPOS_PATH`

if [ ! -f "temp/$RASPOS_FILE" ]; then
    echo "$RASPOS_FILE does not exist. Downloading..."
    wget -P temp $RASPOS_PATH
fi

IMAGE_FILE="temp/$RASPOS_FILE"
SD_DEVICE="/dev/$DEVICE_NAME"

# Burn the image

if [ -b "$SD_DEVICE"1 ]; then
    echo "Partitions exist, I'm too scared to write over them, use fdisk to delete before running again."
    exit
else
    echo "Writing to $SD_DEVICE.  THIS WILL DELETE ALL THE DATA ON THIS DRIVE."
    while true; do
    read -p "  CONTINUE? [Y/N] " response
        case $response in
            [Yy] ) echo "Installing to /dev/$DEVICE_NAME"; break;;
            * ) exit;;
        esac
    done
    unzip -q -c "$IMAGE_FILE" | sudo dd bs=4M of="$SD_DEVICE" status=progress ; sync
fi

# Mount the volumes

SD_MOUNT1="tempmount1"
SD_MOUNT2="tempmount2"

mkdir -p $SD_MOUNT1
mkdir -p $SD_MOUNT2

if grep -qs "$PWD/$SD_MOUNT1 " /proc/mounts; then
    sudo umount "$PWD/$SD_MOUNT1"
fi

if grep -qs "$PWD/$SD_MOUNT2 " /proc/mounts; then
    sudo umount "$PWD/$SD_MOUNT2"
fi

sudo mount "$SD_DEVICE"1 $SD_MOUNT1
sudo mount "$SD_DEVICE"2 $SD_MOUNT2

# Execute the moduloe helper scripts

. modules/ssh.sh
. modules/wifi.sh
. modules/staticip.sh
. modules/hostname.sh
. modules/timezone.sh

# Finally clean up

sudo umount $SD_MOUNT1
sudo umount $SD_MOUNT2

rm -fr $SD_MOUNT1
rm -fr $SD_MOUNT2
