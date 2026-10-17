#!/bin/bash
# Telmi launcher for ArkOS / dArkOS (RK3326 handhelds such as the R36S).
# Standalone: it does NOT need PortMaster. Layout expected on the roms card:
#   ports/Telmi.sh            <- this script
#   ports/telmi/              <- binary and data/res (images, fonts)
#   Stories/ Music/ Saves/    <- at the root of the card (same layout as a Telmi OS card, for Telmi Sync)

PORTSDIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
GAMEDIR="$PORTSDIR/telmi"
DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
BIN="$GAMEDIR/telmi_rk3326.aarch64"
LOG="$GAMEDIR/log.txt"

ESUDO=""
[ "$(id -u)" != "0" ] && ESUDO="sudo"

cd "$GAMEDIR" || exit 1

# Keep the log small (the card is slow and fragile)
[ -f "$LOG" ] && [ "$(wc -c < "$LOG")" -gt 100000 ] && : > "$LOG"
echo "[telmi] launcher invoked $(date)" >> "$LOG" 2>/dev/null
exec > >(tee -a "$LOG") 2>&1

export GAMEDIR
# Stories/, Music/ and Saves/ at the root of the roms card (= a Telmi OS card layout, managed by Telmi Sync).
# Falls back to GAMEDIR/data when the card root does not hold a Stories folder yet.
CARDROOT="$(dirname "$PORTSDIR")"
if [ -d "$CARDROOT/Stories" ] || [ -f "$CARDROOT/autorun.inf" ]; then
  export TELMI_DATA_DIR="$CARDROOT"
fi
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
[ -d "$XDG_RUNTIME_DIR" ] || { XDG_RUNTIME_DIR=/tmp/runtime-$(id -un); mkdir -p "$XDG_RUNTIME_DIR"; }

export SDL_AUDIODRIVER="${SDL_AUDIODRIVER:-alsa}"
export SDL_VIDEODRIVER="${SDL_VIDEODRIVER:-kmsdrm}"
export SDL_VIDEO_EGL_DRIVER="${SDL_VIDEO_EGL_DRIVER:-libEGL.so}"

# Controller mapping: the one shipped with the port, else the one of dArkOS
if [ -z "$SDL_GAMECONTROLLERCONFIG_FILE" ]; then
  for db in "$GAMEDIR/gamecontrollerdb.txt" /opt/inttools/gamecontrollerdb.txt; do
    [ -f "$db" ] && { export SDL_GAMECONTROLLERCONFIG_FILE="$db"; break; }
  done
fi

echo "[telmi] GAMEDIR=$GAMEDIR TELMI_DATA_DIR=${TELMI_DATA_DIR:-$GAMEDIR/data}"
echo "[telmi] Launching at $(date)"
echo "[telmi] SDL_VIDEODRIVER=$SDL_VIDEODRIVER SDL_VIDEO_EGL_DRIVER=$SDL_VIDEO_EGL_DRIVER controllers=${SDL_GAMECONTROLLERCONFIG_FILE:-none}"

BACKLIGHT_DIR="/sys/class/backlight/backlight"
if [ -r "$BACKLIGHT_DIR/max_brightness" ] && [ -r "$BACKLIGHT_DIR/brightness" ]; then
  MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/max_brightness" 2>/dev/null)
  CUR_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/brightness" 2>/dev/null)
  if [ -n "$MAX_BRIGHTNESS" ] && [ "$MAX_BRIGHTNESS" -gt 0 ] && [ "$CUR_BRIGHTNESS" = "0" ]; then
    echo "[telmi] backlight was 0, restoring to max"
    if [ -w "$BACKLIGHT_DIR/brightness" ]; then
      echo "$MAX_BRIGHTNESS" > "$BACKLIGHT_DIR/brightness" 2>/dev/null || true
    else
      $ESUDO sh -c "echo $MAX_BRIGHTNESS > $BACKLIGHT_DIR/brightness" 2>/dev/null || true
    fi
    sleep 0.1
  fi
fi

if [ ! -x "$BIN" ]; then
  echo "[telmi] ERROR: binary missing or not executable: $BIN"
  exit 1
fi

if [ ! -f "$GAMEDIR/data/res/Exo2-Regular.ttf" ] || [ ! -f "$GAMEDIR/data/res/Exo2-Bold.ttf" ]; then
  echo "[telmi] ERROR: required fonts missing in $GAMEDIR/data/res"
  exit 1
fi

if [ ! -f "$GAMEDIR/data/res/selectStories.png" ]; then
  echo "[telmi] ERROR: required UI assets missing in $GAMEDIR/data/res"
  exit 1
fi

echo "[telmi] Note: Use double-tap SELECT+START to quit"

"$BIN"
APP_EXIT_CODE=$?
echo "[telmi] App exit code: $APP_EXIT_CODE"

if [ "$APP_EXIT_CODE" = "194" ] || [ -f "/tmp/telmi_poweroff.flag" ]; then
  echo "[telmi] Poweroff requested by app"
  rm -f /tmp/telmi_poweroff.flag
  sync
  $ESUDO poweroff
  exit 0
fi

# In Telmi mode (started by telmi_kiosk.sh) a normal quit, i.e. double-tap SELECT+START, switches the console off.
if [ "$APP_EXIT_CODE" = "0" ] && [ -n "$TELMI_KIOSK" ]; then
  echo "[telmi] Quit in Telmi mode: powering off"
  sync
  $ESUDO poweroff
  exit 0
fi

# Only CFWs that have a "ui" service need it restarted (ArkOS/dArkOS return to EmulationStation by themselves)
if systemctl list-unit-files ui.service 2>/dev/null | grep -q '^ui.service'; then
  $ESUDO systemctl restart ui
fi

exit $APP_EXIT_CODE
