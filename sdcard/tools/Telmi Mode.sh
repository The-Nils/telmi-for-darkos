#!/bin/bash
# Switch to Telmi mode: the console boots straight into Telmi and stays there until the key combo
# (see /home/ark/.config/modeswitch.conf) is entered. Run "Install Telmi Mode" first.

sudo chmod 666 /dev/tty1
exec > /dev/tty1 2>&1
printf "\033c"

if [ ! -x /usr/local/bin/telmi_kiosk.sh ]; then
  echo "Telmi mode is not installed: run 'Install Telmi Mode' first."; sleep 8; exit 1
fi
if [ ! -f /roms/ports/Telmi.sh ] && [ ! -f /roms2/ports/Telmi.sh ]; then
  echo "The Telmi port is missing (ports/Telmi.sh)."; sleep 8; exit 1
fi

touch /home/ark/.config/.TELMI_MODE
sync  # the flag must survive a reset/power cut right after
echo "Telmi mode enabled. Rebooting..."
echo "Exit with: UP UP DOWN DOWN LEFT RIGHT LEFT RIGHT B A"
sleep 3
# Reboot instead of restarting EmulationStation: Telmi's SDL/kmsdrm init hangs (screen stuck on this text)
# when it is started right after EmulationStation released the display; from a cold boot it works.
sudo systemctl reboot
