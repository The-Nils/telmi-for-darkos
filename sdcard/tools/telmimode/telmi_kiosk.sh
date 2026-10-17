#!/bin/bash
# Telmi kiosk: keeps the Telmi PortMaster port running, relaunches it if it quits.
# Safety net: if Telmi is missing or crashes repeatedly, fall back to emulation mode
# so the device can never end up with a black screen and no way out.

FLAG=/home/ark/.config/.TELMI_MODE
LAUNCHERS=("/roms/ports/Telmi.sh" "/roms2/ports/Telmi.sh")
MAX_FAST_FAILS=3     # consecutive runs shorter than MIN_RUN_SECS => give up
MIN_RUN_SECS=10

trap 'exit 0' TERM INT

# Log on the roms card (readable from a computer) and keep it flushed even if the console is powered off.
KLOG=/roms/tools/telmi_kiosk.log
[ -f "$KLOG" ] && [ "$(wc -c < "$KLOG")" -gt 100000 ] && : > "$KLOG"
[ -d /roms/tools ] && exec >> "$KLOG" 2>&1
( while true; do sync; sleep 2; done ) &
SYNCPID=$!
trap 'kill $SYNCPID 2>/dev/null' EXIT
echo "=== telmi-kiosk start $(date) ==="
sync
echo "uptime: $(cut -d' ' -f1 /proc/uptime)s  plymouth: $(pgrep -x plymouthd >/dev/null && echo running || echo no)  drm-master-users: $(ls /proc/*/fd 2>/dev/null | wc -l) fds"
echo "boot tries: $(cat /home/ark/.config/.telmi_boot_tries 2>/dev/null || echo 0)"
sync

fallback_to_emulation() {
  echo "[telmi-kiosk] $1 -> falling back to emulation mode"
  rm -f "$FLAG"
  sync
  kill $SYNCPID 2>/dev/null
  exec /usr/bin/emulationstation/emulationstation.sh
}

launcher=""
for l in "${LAUNCHERS[@]}"; do
  [ -f "$l" ] && launcher="$l" && break
done
[ -z "$launcher" ] && fallback_to_emulation "Telmi.sh not found in /roms/ports or /roms2/ports"

sudo chmod 666 /dev/tty1 2>/dev/null
export XDG_RUNTIME_DIR=/run/user/$UID/

fast_fails=0
while [ -f "$FLAG" ]; do
  start=$(date +%s)
  TELMI_KIOSK=1 bash "$launcher"
  runtime=$(( $(date +%s) - start ))
  sleep 3  # lets a poweroff requested by Telmi.sh start, and the display be released before a relaunch

  # Telmi asked for poweroff (Telmi.sh already ran `poweroff`): don't relaunch during shutdown
  [ "$(systemctl is-system-running 2>/dev/null)" = "stopping" ] && exit 0

  if [ "$runtime" -lt "$MIN_RUN_SECS" ]; then
    fast_fails=$((fast_fails + 1))
    [ "$fast_fails" -ge "$MAX_FAST_FAILS" ] && fallback_to_emulation "Telmi exited $fast_fails times in a row in <${MIN_RUN_SECS}s"
  else
    fast_fails=0
  fi
done

# Flag removed while running (mode switch): hand over to emulation
kill $SYNCPID 2>/dev/null
exec /usr/bin/emulationstation/emulationstation.sh
