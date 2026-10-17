#!/bin/bash
# Entry point of emulationstation.service (see emulationstation.service.d/telmi-mode.conf).
# Telmi mode  -> kiosk loop, no way out except the key combo handled by modeswitch.service
# Emu mode    -> regular EmulationStation wrapper

FLAG=/home/ark/.config/.TELMI_MODE

# Escape hatch editable from a computer: create an empty file "force_emulation" at the root of the roms partition
# One-shot: the file is consumed, so Telmi mode can be enabled again afterwards.
for f in /roms/force_emulation /roms2/force_emulation; do
  if [ -f "$f" ]; then
    rm -f "$FLAG" "$f"
    sync
  fi
done

if [ -f "$FLAG" ] && [ -x /usr/local/bin/telmi_kiosk.sh ]; then
  exec /usr/local/bin/telmi_kiosk.sh
fi

exec /usr/bin/emulationstation/emulationstation.sh "$@"
