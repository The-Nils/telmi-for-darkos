#!/usr/bin/env python3
"""Leave Telmi mode with a button combo (cheat code).

Runs as root (modeswitch.service). Passively reads every gamepad found under
/dev/input (no grab, so Telmi keeps receiving its inputs). When the combo from
/home/ark/.config/modeswitch.conf is entered while the Telmi flag exists, the flag
is removed and emulationstation.service is restarted, which now starts EmulationStation.

  modeswitch_daemon.py           run the daemon
  modeswitch_daemon.py --learn   print the raw code of every pressed button (to fill MAP_* overrides)
"""

import asyncio
import os
import re
import subprocess
import sys
import time

FLAG = "/home/ark/.config/.TELMI_MODE"
ES_SETTINGS = "/home/ark/.emulationstation/es_settings.cfg"
CONF = "/home/ark/.config/modeswitch.conf"
DEFAULT_COMBO = "UP UP DOWN DOWN LEFT RIGHT LEFT RIGHT B A".split()  # the real Konami code
# Also accepted: the "alternating" variant people often type (seen in the first on-device test).
DEFAULT_COMBO2 = "UP DOWN UP DOWN LEFT RIGHT LEFT RIGHT B A".split()
DEFAULT_TIMEOUT = 3.0

EV_KEY, EV_ABS = 1, 3
ABS_HAT0X, ABS_HAT0Y = 16, 17

# logical button -> evdev key codes (BTN_* values from linux/input-event-codes.h)
DEFAULT_KEYS = {
    "UP": {544}, "DOWN": {545}, "LEFT": {546}, "RIGHT": {547},  # BTN_DPAD_*
    "B": {304}, "A": {305}, "X": {307}, "Y": {308},             # BTN_SOUTH/EAST/NORTH/WEST
    "L": {310}, "R": {311}, "L2": {312}, "R2": {313},
    "SELECT": {314, 704}, "START": {315, 705},  # 704/705: GO-Super Gamepad (R36S)
}


def load_conf(path=CONF):
    """Return (combos, timeout, keymap). COMBO / COMBO2 in the conf; any of them leaves Telmi mode."""
    combo, combo2, timeout = list(DEFAULT_COMBO), list(DEFAULT_COMBO2), DEFAULT_TIMEOUT
    keys = {name: set(codes) for name, codes in DEFAULT_KEYS.items()}
    try:
        with open(path) as f:
            for line in f:
                line = line.split("#", 1)[0].strip()
                if "=" not in line:
                    continue
                k, v = (s.strip() for s in line.split("=", 1))
                if k == "COMBO" and v:
                    combo = v.upper().split()
                elif k == "COMBO2" and v:
                    combo2 = v.upper().split()
                elif k == "TIMEOUT":
                    timeout = float(v)
                elif k.startswith("MAP_"):
                    keys[k[4:].upper()] = {int(c) for c in v.split(",") if c.strip()}
    except FileNotFoundError:
        pass
    except ValueError as e:
        print(f"bad {path}: {e}, using defaults for the bad field", file=sys.stderr)
    return [combo] + ([combo2] if combo2 != combo else []), timeout, keys


def logical_button(etype, code, value, keys):
    """Map a raw evdev event to a logical button name on *press*, else None."""
    if etype == EV_KEY and value == 1:
        for name, codes in keys.items():
            if code in codes:
                return name
    elif etype == EV_ABS and value != 0:
        if code == ABS_HAT0X:
            return "LEFT" if value < 0 else "RIGHT"
        if code == ABS_HAT0Y:
            return "UP" if value < 0 else "DOWN"
    return None


class ComboMatcher:
    def __init__(self, combo, timeout):
        self.combo, self.timeout = combo, timeout
        self.pos, self.last = 0, 0.0

    def feed(self, button, now=None):
        """Feed one logical press; True when the whole combo has just been entered."""
        now = time.monotonic() if now is None else now
        if self.pos and now - self.last > self.timeout:
            self.pos = 0
        self.last = now
        if button == self.combo[self.pos]:
            self.pos += 1
        else:  # wrong key: it may still be the start of a new attempt
            self.pos = 1 if button == self.combo[0] else 0
        if self.pos == len(self.combo):
            self.pos = 0
            return True
        return False


def log(msg):
    """Log line to the roms card (readable from a computer) and to the journal."""
    print(msg, flush=True)
    try:
        with open("/roms/tools/modeswitch.log", "a") as f:
            f.write(time.strftime("%H:%M:%S ") + msg + "\n")
            f.flush()
            os.fsync(f.fileno())
    except OSError:
        pass


def es_ui_locked():
    """True when EmulationStation is in Kid or Kiosk UI mode (menus locked)."""
    try:
        with open(ES_SETTINGS) as f:
            return re.search(r'name="UIMode"\s+value="(Kid|Kiosk)"', f.read(), re.I) is not None
    except OSError:
        return False


def reset_es_ui_mode():
    """Back to the full EmulationStation UI. ES must be stopped first: it rewrites its settings on exit."""
    log("combo entered while EmulationStation is in Kid/Kiosk mode: resetting to Full UI")
    subprocess.run(["systemctl", "stop", "emulationstation"], check=False)
    try:
        with open(ES_SETTINGS) as f:
            lines = f.readlines()
        with open(ES_SETTINGS, "w") as f:  # rewrite in place: keeps the file owner (ark)
            f.writelines(l for l in lines if "UIMode" not in l)
        os.sync()
    except OSError as e:
        log(f"could not edit {ES_SETTINGS}: {e}")
    subprocess.run(["systemctl", "--no-block", "start", "emulationstation"], check=False)


_active_cache = {"t": 0.0, "v": False}


def mode_active():
    """Telmi mode or a locked EmulationStation UI: the only situations where the combo does anything.
    Cached for 2 s so that normal gameplay costs nothing."""
    now = time.monotonic()
    if now - _active_cache["t"] > 2.0:
        _active_cache["v"] = os.path.exists(FLAG) or es_ui_locked()
        _active_cache["t"] = now
    return _active_cache["v"]


def on_combo():
    if os.path.exists(FLAG):
        log("combo entered: switching to emulation mode")
        os.remove(FLAG)
        os.sync()  # make the removal survive an immediate power cut / reset
        subprocess.run(["systemctl", "--no-block", "restart", "emulationstation"], check=False)
    elif es_ui_locked():
        reset_es_ui_mode()
    # else: normal emulation mode with the full UI: the combo does nothing (it is also a game cheat code)


def is_gamepad(dev):
    from evdev import ecodes
    caps = dev.capabilities()
    keys = set(caps.get(ecodes.EV_KEY, []))
    has_hat = ecodes.EV_ABS in caps and ABS_HAT0X in dict(caps[ecodes.EV_ABS])
    return bool(keys & {304, 305, 544, 545}) or has_hat


async def watch(dev, handler):
    try:
        async for ev in dev.async_read_loop():
            handler(dev, ev)
    except OSError:  # device unplugged
        pass


async def main(learn):
    import evdev

    try:  # keep the log small
        if os.path.getsize("/roms/tools/modeswitch.log") > 50000:
            open("/roms/tools/modeswitch.log", "w").close()
    except OSError:
        pass
    combos, timeout, keys = load_conf()
    log("modeswitch started, combos=" + " | ".join(" ".join(c) for c in combos))
    press_log = {"n": 0}
    matchers = [ComboMatcher(c, timeout) for c in combos]
    watched = {}

    def handler(dev, ev):
        if learn:
            if ev.type in (EV_KEY, EV_ABS) and ev.value != 0:
                print(f"{dev.name}: type={ev.type} code={ev.code} value={ev.value}", flush=True)
            return
        button = logical_button(ev.type, ev.code, ev.value, keys)
        if button and mode_active():
            done = False
            for m in matchers:  # feed every matcher: don't short-circuit
                done = m.feed(button) or done
            if press_log["n"] < 300:  # bounded: don't wear the card while children play
                press_log["n"] += 1
                log(f"press {button} -> " + " ".join(f"{m.pos}/{len(m.combo)}" for m in matchers))
            if done:
                on_combo()

    while True:
        for path in evdev.list_devices():
            if path in watched and not watched[path].done():
                continue
            try:
                dev = evdev.InputDevice(path)
                if is_gamepad(dev):
                    log(f"watching {dev.name} ({path})")
                    watched[path] = asyncio.ensure_future(watch(dev, handler))
            except OSError:
                pass
        await asyncio.sleep(10)  # also picks up devices that appear later


if __name__ == "__main__":
    asyncio.run(main("--learn" in sys.argv))
