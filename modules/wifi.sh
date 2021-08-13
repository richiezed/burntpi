SSID=$config_module_wifi_ssid
PSK=$config_module_wifi_psk

FILE_PATH="$SD_MOUNT1/wpa_supplicant.conf"

echo "country=AU" | sudo tee -a $FILE_PATH
echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" | sudo tee -a $FILE_PATH
echo "update_config=1" | sudo tee -a $FILE_PATH
echo | sudo tee -a  $FILE_PATH
echo "network={" | sudo tee -a $FILE_PATH
echo " scan_ssid=1" | sudo tee -a $FILE_PATH
echo " ssid=\"$SSID\"" | sudo tee -a $FILE_PATH
echo " psk=\"$PSK\"" | sudo tee -a $FILE_PATH
echo "}" | sudo tee -a $FILE_PATH
