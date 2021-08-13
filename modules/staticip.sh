ETH_IP=$config_module_staticip_ethip
WLAN_IP=$config_module_staticip_wlanip
GATEWAY_IP=$config_module_staticip_gatewayip

echo | sudo tee -a $SD_MOUNT2/etc/dhcpcd.conf
echo interface eth0 | sudo tee -a $SD_MOUNT2/etc/dhcpcd.conf
echo static ip_address=$ETH_IP/24 | sudo tee -a $SD_MOUNT2/etc/dhcpcd.conf
echo static routers=$GATEWAY_IP | sudo tee -a $SD_MOUNT2/etc/dhcpcd.conf
echo static domain_name_servers=$GATEWAY_IP | sudo tee -a $SD_MOUNT2/etc/dhcpcd.conf
echo | sudo tee -a $SD_MOUNT2/etc/dhcpcd.conf
echo interface wlan0 | sudo tee -a $SD_MOUNT2/etc/dhcpcd.conf
echo static ip_address=$WLAN_IP/24 | sudo tee -a $SD_MOUNT2/etc/dhcpcd.conf
echo static routers=$GATEWAY_IP | sudo tee -a $SD_MOUNT2/etc/dhcpcd.conf
echo static domain_name_servers=$GATEWAY_IP | sudo tee -a $SD_MOUNT2/etc/dhcpcd.conf