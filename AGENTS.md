# AGENTS.md

Règles de travail pour ce dépôt (telmi-for-darkos).

## Releases

- **Les instructions d'installation doivent toujours être répétées dans les notes de la release GitHub**, à chaque release, même pour un simple correctif. Les utilisateurs arrivent par la page Release et ne lisent pas forcément le README.
- Reprendre les étapes de la section « Installation » de `README.md` (et sa version anglaise de `README.en.md`), sans les résumer, et garder les deux langues (français puis anglais) :
  1. télécharger `telmi-for-darkos-<version>.zip` ;
  2. décompresser **à la racine de la partition des roms** (`EASYROMS`), sans dossier englobant, en fusionnant `ports` et `tools` ;
  3. éjecter la carte proprement, la remettre dans la console et démarrer ;
  4. _Options → Tools → `Install Telmi Mode`_ (une seule fois, aussi après une mise à jour du kit) ;
  5. _Options → Tools → `Telmi Mode`_ (la console redémarre puis affiche Telmi).
- Rappeler aussi dans les notes : le prérequis (dArkOS déjà installé, version testée) et le code pour sortir du mode Telmi (haut, haut, bas, bas, gauche, droite, gauche, droite, B, A).
- Puis ajouter ce qui a changé dans la version (correctif / nouveauté), en tête des notes.
- Si l'installation change (nouvelle étape, nouveau fichier), mettre à jour `README.md`, `README.en.md` **et** les notes de release dans le même passage.

## Procédure de release

1. Mettre à jour la version dans `README.md`, `README.en.md` et `docs/BUILD.md` (liens de téléchargement).
2. `scripts/package.sh <version>` construit `dist/telmi-for-darkos-<version>.zip` (`dist/` n'est pas versionné).
3. Commit, push de `main`, tag `v<version>`, puis `gh release create v<version> dist/telmi-for-darkos-<version>.zip` avec les notes décrites ci-dessus.
4. Le dépôt appartient au compte GitHub **The-Nils** : le compte `gh` actif doit être celui-ci pour pousser et publier (`gh auth switch -u The-Nils`). Rebasculer ensuite sur `NilsTessier`.
