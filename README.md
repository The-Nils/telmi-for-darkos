# Telmi pour dArkOS

_[English version](README.en.md)_

> ### 📦 Téléchargement
> **[telmi-for-darkos-1.0.0.zip](https://github.com/The-Nils/telmi-for-darkos/releases/download/v1.0.0/telmi-for-darkos-1.0.0.zip)** · [toutes les versions (Releases)](https://github.com/The-Nils/telmi-for-darkos/releases/latest)

Fait tourner **[Telmi](https://telmi.fr)** (le conteur d'histoires open source pour enfants) sur une console portable **R36S** équipée de **dArkOS**, avec deux modes :

- **Mode Telmi** : la console démarre directement dans Telmi et on ne peut pas en sortir par hasard. On en sort avec un code secret (comme le Konami code).
- **Mode émulation** : l'interface EmulationStation complète, comme d'habitude.

La carte SD est aussi reconnue par **[Telmi Sync](https://github.com/DantSu/Telmi-Sync)** : les histoires et la musique s'envoient depuis l'ordinateur, comme sur une Miyoo Mini.

> ## ⚠️ Prérequis : dArkOS doit déjà être installé
>
> Ce dépôt **n'installe pas dArkOS** et ne documente pas son installation (ce n'est pas son objet).
> Il faut une console qui démarre déjà sous dArkOS : **[github.com/christianhaitian/dArkOS](https://github.com/christianhaitian/dArkOS)** (téléchargements dans _Releases_).
>
> **Version testée** : dArkOS **`v08272026`** (*Debian Trixie*), image `dArkOS_RG351MP_trixie_09022026` (noyau 4.4.189), sur une **R36S** (clone « V5 »).
> Les autres versions de dArkOS et les autres consoles RK3326 sont probablement compatibles, mais non testées (voir [Autres consoles](#autres-consoles)).

## Installation

1. **Récupérer le kit** : télécharger [`telmi-for-darkos-1.0.0.zip`](https://github.com/The-Nils/telmi-for-darkos/releases/download/v1.0.0/telmi-for-darkos-1.0.0.zip) (ou lancer `scripts/package.sh`).
2. **Copier le kit sur la carte SD** : insérer la carte dans l'ordinateur et décompresser le contenu du zip **à la racine de la partition des roms** (celle qui s'appelle `EASYROMS`, avec les dossiers `ports`, `tools`, `gba`…). Accepter de fusionner les dossiers `ports` et `tools`.
3. **Éjecter la carte proprement**, la remettre dans la console et démarrer celle-ci.
4. Dans EmulationStation : **Options → Tools → `Install Telmi Mode`** (une seule fois). Attendre le message « Installed ».
5. **Options → Tools → `Telmi Mode`** : la console redémarre l'interface et affiche Telmi.

C'est tout. Au prochain démarrage, la console revient directement dans Telmi.

## Utilisation

| Objectif                                             | Action                                                                                                                                                                                                   |
| ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Sortir du mode Telmi** (retour à EmulationStation) | Le code : **haut, haut, bas, bas, gauche, droite, gauche, droite, B, A** (moins de 3 secondes entre deux appuis). La variante _haut, bas, haut, bas, gauche, droite, gauche, droite, B, A_ marche aussi. |
| **Revenir en mode Telmi**                            | _Options → Tools → `Telmi Mode`_                                                                                                                                                                         |
| **Éteindre la console depuis Telmi**                 | Double appui sur **SELECT + START** (en mode Telmi, la console s'éteint ; si Telmi est lancé depuis le menu _Ports_, ce geste ramène à EmulationStation)                                                 |
| **Ajouter des histoires / de la musique**            | Avec **Telmi Sync** (la carte est reconnue), ou en copiant les dossiers d'histoires dans `Stories/` et les `.mp3` dans `Music/`                                                                          |
| **Tout désinstaller**                                | _Options → Tools → `Uninstall Telmi Mode`_                                                                                                                                                               |

Le mode choisi est **mémorisé** : si la console est éteinte, redémarrée ou réinitialisée en mode Telmi, elle revient en mode Telmi.

### Telmi Sync

La carte apparaît dans Telmi Sync comme un appareil _Telmi OS_. Pour que Telmi Sync ne touche à rien d'autre, elle se présente en **version 99.0.0** : il ne trouve donc jamais de « mise à jour » à installer.

- Il n'écrit que dans `Stories/`, `Music/` et `Saves/`.
- **Ne jamais cliquer** sur « Installer / formater Telmi OS » : cette action **formate** le disque.

## Conseils pour un usage par des enfants

Deux réglages de dArkOS rendent l'ensemble plus simple et plus robuste. Ils se font **dans EmulationStation** (bouton **START** pour ouvrir le menu principal).

### 1. Éteindre la console d'un simple appui sur le bouton d'alimentation

Par défaut, dArkOS met la console **en veille** sur un appui court et ne l'éteint que sur un appui long. Pour qu'un **appui court éteigne** la console :

**START → ADVANCED SETTINGS → `SWITCH POWER BUTTON TAP TO OFF`** (activer l'option), puis valider et quitter le menu.

L'appui long met alors la console en veille. Un enfant n'a plus qu'à appuyer une fois sur le bouton d'alimentation pour éteindre.

### 2. Activer le mode enfant d'EmulationStation

Ce mode **masque tous les menus de configuration** d'EmulationStation : l'enfant ne peut plus modifier les réglages par erreur.

**START → UI SETTINGS → `UI MODE` → `Kid`** (ou `Kiosk`), puis confirmer. Un message affiche alors le code de déverrouillage.

Pour **en sortir** (retrouver l'interface complète) : sur l'écran des systèmes, saisir le Konami code

> **haut, haut, bas, bas, gauche, droite, gauche, droite, B, A**

Si EmulationStation ne recharge pas l'interface à la fin du code, appuyer une fois de plus sur **A** pour valider.

> Faire les réglages et installer le kit (`Install Telmi Mode`, `Telmi Mode`) **avant** d'activer le mode enfant : ce mode masque aussi le menu *Tools*.
> Ce mode agit sur EmulationStation. En mode Telmi, la sortie reste le code décrit plus haut (voir *Utilisation*).

## En cas de problème

- **La console est bloquée en mode Telmi** (le code ne marche pas) : éteindre la console (appui long sur le bouton), insérer la carte dans l'ordinateur, créer un **fichier vide nommé `force_emulation`** à la racine de la partition `EASYROMS`, puis remettre la carte. La console démarre une fois sur EmulationStation (le fichier est consommé).
- **Écran noir au démarrage** : ça n'a normalement rien à voir avec Telmi (voir la documentation de dArkOS pour le modèle d'écran concerné). Si cela se produit juste après `Telmi Mode`, utiliser `force_emulation` comme ci-dessus.
- **Journaux** (lisibles depuis l'ordinateur) : `tools/telmi_kiosk.log` (démarrage de Telmi), `tools/modeswitch.log` (touches vues par le code secret), `ports/telmi/log.txt`.
- **Éteindre la console par le menu** dès que possible : une coupure brutale peut abîmer la carte.

## Autres consoles

Le code secret lit les touches de la manette de la R36S (_GO-Super Gamepad_). Sur une autre console, si le code ne réagit pas :

1. lancer `Options → Tools → Telmi Learn Keys` et appuyer une fois sur chaque touche ;
2. lire `tools/learn_keys.log` sur l'ordinateur ;
3. ajouter des lignes `MAP_UP=…`, `MAP_B=…` dans `/home/ark/.config/modeswitch.conf` (voir les commentaires du fichier).

## Ce que ça modifie

Rien dans l'image dArkOS elle-même. `Install Telmi Mode` copie quelques petits fichiers : voir [docs/HOW-IT-WORKS.md](docs/HOW-IT-WORKS.md). `Uninstall Telmi Mode` les retire. **Sauvegarder la carte** avant d'essayer : ce projet modifie des fichiers système et est fourni sans garantie.

## Pour les développeurs

- Fonctionnement : [docs/HOW-IT-WORKS.md](docs/HOW-IT-WORKS.md)
- Recompiler le programme Telmi : [docs/BUILD.md](docs/BUILD.md)

## Crédits et licence

- **Telmi OS** (conteur d'histoires, version **1.10.4**) : [DantSu/Telmi-story-teller](https://github.com/DantSu/Telmi-story-teller) - GPL-3.0. La couche de plateforme pour ArkOS / dArkOS s'appuie sur l'[adaptation PortMaster](https://github.com/The-Nils/Telmi-story-teller-portmaster).
- **Telmi Sync** : [DantSu/Telmi-Sync](https://github.com/DantSu/Telmi-Sync).
- **dArkOS** : [christianhaitian/dArkOS](https://github.com/christianhaitian/dArkOS).

Ce dépôt est un projet indépendant, non affilié à ces projets. Licence : **GPL-3.0** (voir `LICENSE`), car il distribue un programme dérivé de Telmi OS.
