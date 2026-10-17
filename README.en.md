# Telmi for dArkOS

*[Version française](README.md)*

> ### 📦 Download
> **[telmi-for-darkos-1.0.0.zip](https://github.com/The-Nils/telmi-for-darkos/releases/download/v1.0.0/telmi-for-darkos-1.0.0.zip)** · [all versions (Releases)](https://github.com/The-Nils/telmi-for-darkos/releases/latest)

Runs **[Telmi](https://telmi.fr)** (the open source story teller for children) on an **R36S** handheld running **dArkOS**, with two modes:

- **Telmi mode**: the console boots straight into Telmi and cannot be left by accident. A secret button combo (Konami-style) leaves it.
- **Emulation mode**: the full EmulationStation interface, as usual.

The SD card is also recognized by **[Telmi Sync](https://github.com/DantSu/Telmi-Sync)**, so stories and music are sent from the computer like on a Miyoo Mini.

> ## ⚠️ Prerequisite: dArkOS must already be installed
>
> This repository does **not** install dArkOS and does not document how to (out of scope).
> You need a console that already boots dArkOS: **[github.com/christianhaitian/dArkOS](https://github.com/christianhaitian/dArkOS)** (see *Releases*).
>
> **Tested version**: dArkOS **`v08272026`** (*Debian Trixie*), image `dArkOS_RG351MP_trixie_09022026` (kernel 4.4.189), on an **R36S** ("V5" clone).
> Other dArkOS versions and other RK3326 consoles are probably compatible but untested.

## Install

1. Download [`telmi-for-darkos-1.0.0.zip`](https://github.com/The-Nils/telmi-for-darkos/releases/download/v1.0.0/telmi-for-darkos-1.0.0.zip) (or run `scripts/package.sh`).
2. Put the SD card in your computer and unzip the content **at the root of the roms partition** (`EASYROMS`: the one with `ports`, `tools`, `gba`…). Merge the `ports` and `tools` folders.
3. Eject the card, put it back in the console, boot.
4. In EmulationStation: **Options → Tools → `Install Telmi Mode`** (once). Wait for "Installed".
5. **Options → Tools → `Telmi Mode`**. The console restarts its interface and shows Telmi.

## Use

| I want to… | I do… |
|---|---|
| **Leave Telmi mode** | **UP, UP, DOWN, DOWN, LEFT, RIGHT, LEFT, RIGHT, B, A** (less than 3 s between presses). *UP, DOWN, UP, DOWN, LEFT, RIGHT, LEFT, RIGHT, B, A* also works. |
| **Go back to Telmi mode** | *Options → Tools → `Telmi Mode`* |
| **Power off from Telmi** | Double-tap **SELECT + START** (in Telmi mode the console powers off; when Telmi is started from the *Ports* menu it returns to EmulationStation) |
| **Add stories / music** | With **Telmi Sync** (the card is recognized), or copy story folders into `Stories/` and `.mp3` files into `Music/` |
| **Uninstall** | *Options → Tools → `Uninstall Telmi Mode`* |

The chosen mode is remembered across power cycles and resets.

**Telmi Sync:** the card shows up as a *Telmi OS* device with version **99.0.0**, so Telmi Sync never finds an "update" to install. Never click "Install / format Telmi OS": it **formats** the disk.

## Tips for use by children

Two dArkOS settings make everything simpler and more robust. Both are set **in EmulationStation** (press **START** to open the main menu).

### 1. Power off with a single tap on the power button

By default dArkOS **suspends** the console on a short press and powers off only on a long press. To make a **short press power off**:

**START → ADVANCED SETTINGS → `SWITCH POWER BUTTON TAP TO OFF`** (turn it on), then save and leave the menu.

A long press then suspends the console. A child just taps the power button once to switch the console off.

### 2. Turn on EmulationStation's kid mode

It **hides all configuration menus** so settings cannot be changed by accident.

**START → UI SETTINGS → `UI MODE` → `Kid`** (or `Kiosk`), then confirm. A message shows the unlock code.

To **leave** it (back to the full UI), on the systems screen enter the Konami code

> **UP, UP, DOWN, DOWN, LEFT, RIGHT, LEFT, RIGHT, B, A**

If EmulationStation does not reload its interface at the end of the code, press **A** once more to confirm.

> Do the setup and install the kit (`Install Telmi Mode`, `Telmi Mode`) **before** enabling kid mode: it also hides the *Tools* menu.
> This mode applies to EmulationStation. In Telmi mode the way out remains the combo described above (see *Use*).

## Troubleshooting

- **Stuck in Telmi mode:** power off (long press), put the card in a computer, create an **empty file named `force_emulation`** at the root of `EASYROMS`, put the card back. The console boots once to EmulationStation (the file is consumed).
- **Logs:** `tools/telmi_kiosk.log`, `tools/modeswitch.log`, `ports/telmi/log.txt`.
- **Other consoles:** run `Tools → Telmi Learn Keys`, read `tools/learn_keys.log`, then add `MAP_UP=…`, `MAP_B=…` lines to `/home/ark/.config/modeswitch.conf`.

## What it changes

Nothing in the dArkOS image itself. `Install Telmi Mode` copies a few small files (see [docs/HOW-IT-WORKS.md](docs/HOW-IT-WORKS.md)); `Uninstall Telmi Mode` removes them. **Back up your card first**: this modifies system files and comes with no warranty.

## Credits and license

Based on [Telmi OS](https://github.com/DantSu/Telmi-story-teller) **1.10.4** (DantSu), GPL-3.0, with a platform layer built on the [PortMaster port](https://github.com/The-Nils/Telmi-story-teller-portmaster); [dArkOS](https://github.com/christianhaitian/dArkOS). Independent project, not affiliated. License: **GPL-3.0**. Rebuilding the binary: [docs/BUILD.md](docs/BUILD.md).
