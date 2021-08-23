SERVICE_UNIT=$SD_MOUNT2/etc/systemd/system/firstboot.service
RUN_ONCE=$SD_MOUNT2/usr/bin/runonce

echo [Unit] | sudo tee -a $SERVICE_UNIT
echo Description=First run actions | sudo tee -a $SERVICE_UNIT
echo Wants=network-online.target | sudo tee -a $SERVICE_UNIT
echo After=network-online.target | sudo tee -a $SERVICE_UNIT
echo Wants=time-sync.target | sudo tee -a $SERVICE_UNIT
echo After=time-sync.target | sudo tee -a $SERVICE_UNIT
echo | sudo tee -a $SERVICE_UNIT
echo [Service] | sudo tee -a $SERVICE_UNIT
echo Type=oneshot | sudo tee -a $SERVICE_UNIT
echo ExecStart=/usr/bin/runonce | sudo tee -a $SERVICE_UNIT
echo | sudo tee -a $SERVICE_UNIT
echo [Install] | sudo tee -a $SERVICE_UNIT
echo WantedBy=multi-user.target | sudo tee -a $SERVICE_UNIT

echo '#! /bin/bash' | sudo tee -a $RUN_ONCE
echo 'FILES="/home/pi/firstboot/"*' | sudo tee -a $RUN_ONCE
echo 'for f in $FILES' | sudo tee -a $RUN_ONCE
echo 'do' | sudo tee -a $RUN_ONCE
echo '   [ -f "$f" ] && echo "Processing $f file..." && chmod u+x $f && $f' | sudo tee -a $RUN_ONCE
echo 'done' | sudo tee -a $RUN_ONCE
echo 'rm /etc/systemd/system/multi-user.target.wants/firstboot.service' | sudo tee -a $RUN_ONCE
echo 'rm /etc/systemd/system/firstboot.service' | sudo tee -a $RUN_ONCE
echo 'rm $0' | sudo tee -a $RUN_ONCE

sudo chmod 644 $SD_MOUNT2/etc/systemd/system/firstboot.service
sudo chmod 755 $SD_MOUNT2/usr/bin/runonce
sudo ln -s /etc/systemd/system/firstboot.service $SD_MOUNT2/etc/systemd/system/multi-user.target.wants/firstboot.service
sudo ln -s /lib/systemd/system/systemd-time-wait-sync.service $SD_MOUNT2/etc/systemd/system/sysinit.target.wants/systemd-time-wait-sync.service


