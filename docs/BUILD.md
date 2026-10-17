# Recompiler le programme Telmi

Le binaire `sdcard/ports/telmi/telmi_rk3326.aarch64` est déjà fourni. Une recompilation n'est utile que pour modifier Telmi lui-même.

Il est compilé à partir de **Telmi OS 1.10.4** (dépôt officiel [DantSu/Telmi-story-teller](https://github.com/DantSu/Telmi-story-teller), étiquette `1.10.4`) auquel s'applique le correctif `build/telmi-port-changes.patch`. Ce correctif ajoute :

- une couche de plateforme (`src/platform/portmaster/`) pour les consoles ArkOS / dArkOS (entrées, affichage, luminosité, batterie, chemins) ;
- la variable `TELMI_DATA_DIR` (histoires, musique et sauvegardes à la racine de la carte, comme sur une carte Telmi OS) ;
- les scripts de compilation (`Dockerfile.portmaster`, `portmaster/scripts/`) ;
- le lanceur `portmaster/telmi.sh`, copié dans le kit sous le nom `sdcard/ports/Telmi.sh`.

**Docker** est nécessaire. La compilation utilise une Debian *Buster* pour rester compatible avec les anciennes bibliothèques système (le programme tourne aussi sous dArkOS / Debian Trixie).

```bash
git clone https://github.com/DantSu/Telmi-story-teller.git telmi-os
cd telmi-os
git checkout 1.10.4
git apply ../build/telmi-port-changes.patch

docker build -t telmi-builder-portmaster -f Dockerfile.portmaster .
docker run --rm -v "$(pwd)":/workspace telmi-builder-portmaster \
    bash portmaster/scripts/build_portmaster.sh
```

Le binaire est produit dans `dist/portmaster-build/telmi_rk3326.aarch64`. Le copier dans `sdcard/ports/telmi/`. La compilation est reproductible : le binaire obtenu est identique, octet pour octet, à celui du kit.

## Mettre à jour vers une nouvelle version de Telmi OS

1. Se placer sur la nouvelle étiquette du dépôt officiel et appliquer le correctif. S'il ne s'applique plus, c'est que le code a changé aux endroits touchés (surtout `src/storyTeller/storyTeller.c` et `sdl_helper.h`) : résoudre les différences à la main, puis régénérer le correctif avec `git diff <étiquette> > build/telmi-port-changes.patch`.
2. Recompiler comme ci-dessus et vérifier le démarrage sur une console.
3. Remplacer le binaire dans `sdcard/ports/telmi/` et mettre à jour la version mentionnée dans le README.

## Créer le zip à distribuer

```bash
scripts/package.sh 1.0.1      # -> dist/telmi-for-darkos-1.0.1.zip
```
