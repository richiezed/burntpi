LMS_SERVER=$config_software_squeezelite_server
PLAYER_NAME=$config_software_squeezelite_playername

wget -qO - squeezelite https://sourceforge.net/projects/lmsclients/files/squeezelite/linux/squeezelite-1.9.9.1386-armhf.tar.gz/download | tar -zxvf - squeezelite
sudo mv squeezelite /usr/bin

sudo rm /lib/systemd/system/squeezelite.service

echo [Unit] | sudo tee -a -a /lib/systemd/system/squeezelite.service
echo Description=Squeezelite Daemon | sudo tee -a -a /lib/systemd/system/squeezelite.service
echo | sudo tee -a -a /lib/systemd/system/squeezelite.service
echo Requires=network.target sound.target | sudo tee -a -a /lib/systemd/system/squeezelite.service
echo After=network.target sound.target | sudo tee -a /lib/systemd/system/squeezelite.service
echo | sudo tee -a /lib/systemd/system/squeezelite.service
echo [Service] | sudo tee -a /lib/systemd/system/squeezelite.service
echo Type=simple | sudo tee -a /lib/systemd/system/squeezelite.service
echo | sudo tee -a /lib/systemd/system/squeezelite.service
echo | sudo tee -a /lib/systemd/system/squeezelite.service
echo User=pi | sudo tee -a /lib/systemd/system/squeezelite.service
echo | sudo tee -a /lib/systemd/system/squeezelite.service
echo ExecStart=/usr/bin/squeezelite -s "$LMS_SERVER" -n "$PLAYER_NAME" | sudo tee -a /lib/systemd/system/squeezelite.service
echo | sudo tee -a /lib/systemd/system/squeezelite.service
echo [Install] | sudo tee -a /lib/systemd/system/squeezelite.service
echo WantedBy=multi-user.target | sudo tee -a /lib/systemd/system/squeezelite.service

sudo systemctl enable squeezelite.service
sudo systemctl start squeezelite.service 