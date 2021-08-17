HOME_ROOT=$SD_MOUNT2/home/pi

if [ -z "$config_module_credentials_defaultuser_pubkey" ] ; then
    echo "Pubkey not set"
else
    mkdir -p $HOME_ROOT/.ssh
    sudo chmod 700 $HOME_ROOT/.ssh
    cat $config_module_credentials_defaultuser_pubkey >> $HOME_ROOT/.ssh/authorized_keys
    sudo chmod 600 $HOME_ROOT/.ssh/authorized_keys
fi
