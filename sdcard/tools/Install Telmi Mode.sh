#!/bin/bash
# Installs the Telmi mode switch on a dArkOS console (run once, from Options > Tools).
# It copies a few small files into the system. It does NOT switch to Telmi mode: run "Telmi Mode" afterwards.
# Reverse with "Uninstall Telmi Mode". Safe to run again (it also updates an existing install).

P="$(dirname "$(readlink -f "$0")")/telmimode"
ROMS="$(dirname "$(dirname "$P")")"

sudo chmod 666 /dev/tty1
exec > /dev/tty1 2>&1
printf "\033c"
echo "=== Telmi mode: install ==="

fail() { echo; echo "ERROR: $1"; sleep 10; exit 1; }

[ -x /usr/bin/emulationstation/emulationstation.sh ] || fail "this does not look like dArkOS (EmulationStation launcher not found)."
[ -f /etc/systemd/system/emulationstation.service ]   || fail "emulationstation.service not found (is this dArkOS?)."
[ -f "$P/telmi_kiosk.sh" ]                            || fail "files are missing next to this script ($P)."
[ -f "$ROMS/ports/Telmi.sh" ]                         || fail "the Telmi port is missing ($ROMS/ports/Telmi.sh)."
python3 -c "import evdev" 2>/dev/null                 || fail "python3-evdev is missing (sudo apt install python3-evdev)."

sudo cp "$P/telmi_mode_launcher.sh" "$P/telmi_kiosk.sh" "$P/modeswitch_daemon.py" /usr/local/bin/
sudo chmod 755 /usr/local/bin/telmi_mode_launcher.sh /usr/local/bin/telmi_kiosk.sh /usr/local/bin/modeswitch_daemon.py
sudo cp "$P/modeswitch.service" /etc/systemd/system/modeswitch.service
sudo mkdir -p /etc/systemd/system/emulationstation.service.d
sudo cp "$P/telmi-mode.conf" /etc/systemd/system/emulationstation.service.d/telmi-mode.conf
[ -f /home/ark/.config/modeswitch.conf ] || cp "$P/modeswitch.conf" /home/ark/.config/modeswitch.conf
sudo systemctl daemon-reload
sudo systemctl enable modeswitch >/dev/null 2>&1
sudo systemctl restart modeswitch

echo
echo "Installed."
echo "  - Run 'Telmi Mode' (Tools) to boot straight into Telmi."
echo "  - Leave Telmi mode with the key combo:"
echo "      UP UP DOWN DOWN LEFT RIGHT LEFT RIGHT B A"
echo "  - Stuck? Create an empty file named force_emulation"
echo "    at the root of the card (from a computer)."
sleep 12
