DISK_LIST=$(lsblk -do name,tran,size)

DISK_COUNT=$(echo "$DISK_LIST" | grep sd | wc -l)
USB_DISK_COUNT=$(echo "$DISK_LIST" | grep sd | grep usb | wc -l)

echo "You have $DISK_COUNT disks I can find"

if [ "$USB_DISK_COUNT" == "1" ]; then
    DEVICE_NAME=$(echo "$DISK_LIST" | grep sd | grep usb | awk '{split($0,a," "); print a[1]}')
    DEVICE_DESC="$(cat /sys/block/$DEVICE_NAME/device/vendor) $(cat /sys/block/$DEVICE_NAME/device/model)"
    DEVICE_SIZE=$(echo "$DISK_LIST" | grep sd | grep usb | awk '{split($0,a," "); print a[3]}')
    echo "You have $USB_DISK_COUNT USB disk(s) I can find"
else
    echo "No SD cards found, please insert and try again."; exit
fi

echo This is /dev/$DEVICE_NAME which is a $DEVICE_DESC with size of "$DEVICE_SIZE"

while true; do
    read -p "Do you wish to install to /dev/$DEVICE_NAME? [Y/N] " response
    case $response in
        [Yy] ) echo "Installing to /dev/$DEVICE_NAME"; break;;
        [Nn]* ) echo -e "Unable to find correct device for installation.\nExiting..."; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
