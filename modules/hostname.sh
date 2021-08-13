NEW_HOSTNAME=$config_module_hostname
OLD_HOSTNAME="raspberrypi"

FILE_PATH=$SD_MOUNT2/etc

sudo sed -i "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" $FILE_PATH/hostname
sudo sed -i "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" $FILE_PATH/hosts