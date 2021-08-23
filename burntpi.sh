#! /bin/bash
## USAGE ./image.sh
## Configuration is read from image.yaml in the same directory

## Standard paths to image files
## TODO: Somehow get these dynmaically, otherwise requires an update for each new Raspberry Pi OS release

LITE_PATH="https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip"
STANDARD_PATH="https://downloads.raspberrypi.org/raspios_armhf/images/raspios_armhf-2021-05-28/2021-05-07-raspios-buster-armhf.zip"
FULL_PATH="https://downloads.raspberrypi.org/raspios_full_armhf/images/raspios_full_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-full.zip"

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
WORKING_DIR=$HOME/.burntpi
mkdir -p $WORKING_DIR

set -e

# Load the configuration
. $SCRIPT_DIR/readconfig.sh
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

. $SCRIPT_DIR/sddevice.sh

# Download the image if it doesn't exist

if [ -z "$RASPOS_PATH" ] ; then
    echo "Error selecting image"
    exit 1
fi

RASPOS_FILE=`basename $RASPOS_PATH`

if [ ! -f "$WORKING_DIR/images/$RASPOS_FILE" ]; then
    echo "$RASPOS_FILE does not exist. Downloading..."
    wget -P $WORKING_DIR/images $RASPOS_PATH
fi

IMAGE_FILE="$WORKING_DIR/images/$RASPOS_FILE"
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

SD_MOUNT1="$WORKING_DIR/tempmount1"
SD_MOUNT2="$WORKING_DIR/tempmount2"

mkdir -p $SD_MOUNT1
mkdir -p $SD_MOUNT2

if grep -qs "$SD_MOUNT1 " /proc/mounts; then
    sudo umount "$SD_MOUNT1"
fi

if grep -qs "$SD_MOUNT2 " /proc/mounts; then
    sudo umount "$SD_MOUNT2"
fi

sudo mount "$SD_DEVICE"1 $SD_MOUNT1
sudo mount "$SD_DEVICE"2 $SD_MOUNT2

# Execute the module helper scripts defined in theconfig file

compgen -A variable | grep ^config_module_[a-zA-Z]*[^_]$ | while read -r line ; do
    MODULE_SCRIPT=
    echo "Found config for $line. Calling $(echo $line | sed 's/config_module_//').sh helper script"
    . $SCRIPT_DIR/modules/$(echo $line | sed 's/config_module_//').sh
done

FIRST_BOOT=$SD_MOUNT2/home/pi/firstboot


compgen -A variable | grep ^config_software_[a-zA-Z]*[^_]$ | while read -r section ; do
    if [ ! -d "$FIRST_BOOT" ]; then
        mkdir -p $FIRST_BOOT
        . $SCRIPT_DIR/firstboot.sh
    fi
    BUILD_SCRIPT=install_$(echo $section | sed 's/config_software_//').sh
    echo "Found config for $section. Copying $BUILD_SCRIPT build script"
    cp $SCRIPT_DIR/builds/$BUILD_SCRIPT $FIRST_BOOT
    compgen -A variable | grep "^"$section"_[a-zA-Z]*[^_]$" | while read -r sectionconfig ; do
        echo "Found config for $sectionconfig"
        echo $FIRST_BOOT/$BUILD_SCRIPT
        sed -i "1s/^/$sectionconfig=${!sectionconfig}\n/" $FIRST_BOOT/$BUILD_SCRIPT
    done
done

# Finally clean up

sudo umount $SD_MOUNT1
sudo umount $SD_MOUNT2

rm -fr $SD_MOUNT1
rm -fr $SD_MOUNT2
