#!/bin/bash
# Optional, for consoles other than the R36S: run from Options > Tools, then press every button once
# (UP DOWN LEFT RIGHT A B X Y L R SELECT START). The raw codes are logged for 2 minutes to
# "learn_keys.log" next to this script (read it on a computer) and shown on screen.
# Use them as MAP_<BUTTON>=<code> lines in /home/ark/.config/modeswitch.conf if the combo does not work.

DIR="$(dirname "$(readlink -f "$0")")"
LOG="$DIR/learn_keys.log"

sudo chmod 666 /dev/tty1
printf "\033c" > /dev/tty1
{
  echo "=== $(date) ==="
  tr -d '\0' < /proc/device-tree/model; echo
  cat /home/ark/.config/.DEVICE 2>/dev/null | tr -d '\0'; echo
  cat /proc/bus/input/devices
  echo "=== press: UP DOWN LEFT RIGHT A B X Y L1 R1 L2 R2 SELECT START (120 s) ==="
  sudo timeout 120 python3 -u "$DIR/telmimode/modeswitch_daemon.py" --learn 2>&1
  echo "=== done ==="
} 2>&1 | tee "$LOG" > /dev/tty1
sync
sleep 3
