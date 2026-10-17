# Comment ça marche

## Sur la partition des roms (copiée telle quelle)

| Fichier | Rôle |
|---|---|
| `ports/Telmi.sh` | Lanceur de Telmi (sans PortMaster). Règle l'affichage (`kmsdrm`), les manettes (table de dArkOS), puis lance le programme. |
| `ports/telmi/telmi_rk3326.aarch64` | Le programme Telmi 1.10.4 (compilé pour aarch64). |
| `ports/telmi/data/res/` | Images et polices de Telmi. |
| `autorun.inf` | Annonce la carte comme *TelmiOS-v99.0.0* à Telmi Sync. |
| `Saves/.parameters`, `Stories/`, `Music/`, `Saves/` | Disposition d'une carte Telmi OS : Telmi Sync y lit et écrit. Telmi lit aussi ces dossiers (variable `TELMI_DATA_DIR`, voir ci-dessous). |
| `tools/*.sh` | Les entrées du menu *Tools* (installer, activer, désinstaller, apprendre les touches). |
| `tools/telmimode/` | Les fichiers que `Install Telmi Mode` copie dans le système. |

## Ce que `Install Telmi Mode` copie dans dArkOS

| Destination | Fichier |
|---|---|
| `/usr/local/bin/telmi_mode_launcher.sh` | Point d'entrée de `emulationstation.service` : démarre le mode Telmi si le drapeau existe, sinon EmulationStation. |
| `/usr/local/bin/telmi_kiosk.sh` | Boucle du mode Telmi : relance Telmi s'il se ferme, et **retombe sur EmulationStation** s'il est absent ou plante trois fois de suite en moins de 10 s (filet de sécurité). |
| `/usr/local/bin/modeswitch_daemon.py` + `/etc/systemd/system/modeswitch.service` | Service qui écoute le code secret sur la manette (lecture passive via `evdev`, il ne bloque pas Telmi). |
| `/etc/systemd/system/emulationstation.service.d/telmi-mode.conf` | Fragment systemd qui remplace la commande de démarrage par `telmi_mode_launcher.sh` (sans modifier le service d'origine). |
| `/home/ark/.config/modeswitch.conf` | Réglages du code secret (créé s'il n'existe pas). |

Le mode courant est un simple fichier : `/home/ark/.config/.TELMI_MODE`. Présent = mode Telmi. Il est écrit sur la carte et synchronisé (`sync`), donc il survit à un redémarrage ou à une coupure.

## Quitter Telmi

Le double appui sur SELECT + START fait quitter le programme (code de sortie 0). `Telmi.sh` le détecte : en mode Telmi (variable `TELMI_KIOSK` définie par `telmi_kiosk.sh`), il éteint la console ; autrement il rend la main à EmulationStation. Une fermeture anormale (plantage) fait relancer Telmi par `telmi_kiosk.sh`, avec un délai de 3 s.

## Sortie du mode Telmi

`modeswitch_daemon.py` suit les appuis sur la croix, A et B. Quand la séquence est complète **et** que le drapeau existe, il le supprime et redémarre `emulationstation.service`, qui lance alors EmulationStation. En mode normal il ne fait rien (le code est aussi un code de triche de jeux).

Le délai entre deux appuis est de 3 s. Les séquences et les codes de touches se règlent dans `/home/ark/.config/modeswitch.conf`.

## Données de Telmi (`TELMI_DATA_DIR`)

Telmi lit ses histoires dans `<GAMEDIR>/data/Stories` par défaut. `Telmi.sh` définit `TELMI_DATA_DIR` sur la racine de la carte quand `Stories/` ou `autorun.inf` y existent, pour que Telmi et Telmi Sync partagent les mêmes dossiers. Ce changement est dans `build/telmi-port-changes.patch`.

## Échappatoire

Un fichier vide `force_emulation` à la racine de la carte (créé depuis l'ordinateur) supprime le drapeau au prochain démarrage, puis se supprime lui-même.
