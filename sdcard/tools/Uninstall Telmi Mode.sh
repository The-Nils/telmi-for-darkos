#!/bin/bash
sudo chmod 666 /dev/tty1
exec > /dev/tty1 2>&1
printf "\033c"
rm -f /home/ark/.config/.TELMI_MODE
sudo systemctl disable --now modeswitch
sudo rm -f /etc/systemd/system/modeswitch.service /etc/systemd/system/emulationstation.service.d/telmi-mode.conf
sudo rmdir /etc/systemd/system/emulationstation.service.d 2>/dev/null
sudo rm -f /usr/local/bin/telmi_mode_launcher.sh /usr/local/bin/telmi_kiosk.sh /usr/local/bin/modeswitch_daemon.py
sudo systemctl daemon-reload
echo "Uninstalled. Restarting EmulationStation."
sleep 3
sudo systemctl restart emulationstation
