TEST_DIR="$(dirname "$(readlink -f "$0")")"

cp $TEST_DIR/image.yaml.test $PWD/image.yaml
sed -i "s#pubkey\: \@PATH#pubkey\: $TEST_DIR#g" $PWD/image.yaml

$TEST_DIR/../burntpi.sh

#SD_MOUNT1="testmount1"
SD_MOUNT2="testmount2"

#mkdir -p $SD_MOUNT1
mkdir -p $SD_MOUNT2

DISK_LIST=$(lsblk -do name,tran,size)
DEVICE_NAME=$(echo "$DISK_LIST" | grep sd | grep usb | awk '{split($0,a," "); print a[1]}')
SD_DEVICE=/dev/$DEVICE_NAME

echo $SD_DEVICE

#if grep -qs "$PWD/$SD_MOUNT1 " /proc/mounts; then
#    sudo umount "$PWD/$SD_MOUNT1"
#fi

if grep -qs "$PWD/$SD_MOUNT2 " /proc/mounts; then
    sudo umount "$PWD/$SD_MOUNT2"
fi

#sudo mount "$SD_DEVICE"1 $SD_MOUNT1
sudo mount "$SD_DEVICE"2 $SD_MOUNT2

hostname="coolnewpi"
if [ "$hostname" == "$(cat $SD_MOUNT2/etc/hostname)" ] ;then
    echo "Hostname test passes"
else
    echo "Hostname test does not pass"
fi

#sudo umount $SD_MOUNT1
sudo umount $SD_MOUNT2

#rm -fr $SD_MOUNT1
rm -fr $SD_MOUNT2