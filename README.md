# PYTHAGOR OS

Distribution Linux personnelle — **une recette, deux éditions**.

```
 ___  _   _ _____ _  _   _    ___  ___  ___
| _ \| | | |_   _| || | /_\  / __|/ _ \| _ \
|  _/| |_| | | | | __ |/ _ \| (_ | (_) |   /
|_|   \___/  |_| |_||_/_/ \_\\___|\___/|_|_\

                    PYTHAGOR OS 0.1
```

## Architecture

Le principe : un **seul jeu de branding + paquets + config** (`common/`), décliné
en deux cibles par simple changement d'architecture.

```
common/  ──┬──> desktop/  debootstrap amd64 + live-build ──> pythagor-os.iso   (PC, bootable USB)
           └──> mobile/   debootstrap arm64               ──> rootfs.tar.gz    (Android)
                                                              ├─ aujourd'hui : proot dans Termux (sans root)
                                                              └─ plus tard   : image bootable (bootloader déverrouillé requis)
```

Le même rootfs arm64 qui tourne en proot aujourd'hui est celui qu'on injectera
dans une image bootable le jour où un appareil déverrouillable est disponible.
Rien n'est à refaire.

## Base technique

| Choix | Valeur | Pourquoi |
|---|---|---|
| Base | Debian 12 `bookworm` | `debootstrap` produit amd64 **et** arm64 avec la même commande ; `live-build` fait l'ISO |
| Édition PC | ISO hybride BIOS+UEFI | boot sur clé USB, machines anciennes et récentes |
| Édition mobile | rootfs arm64 | `proot` (sans root) → plus tard image bootable |
| Build | conteneur Debian | live-build exige Linux + root, impossible nativement sur macOS |

## État des cibles

| Cible | Statut | Prérequis |
|---|---|---|
| PC — ISO live USB | **faisable** | conteneur de build |
| Android — proot/Termux, sans root | **faisable sur ton CAMON 30S** | Termux |
| Android — boot réel (remplace le système) | **bloqué** | bootloader déverrouillé + sources kernel de l'appareil |

### Pourquoi le boot réel est bloqué sur le CAMON 30S

Transsion (Tecno/Infinix/itel) ne publie pas les sources kernel de l'appareil,
le déverrouillage bootloader n'est pas exposé en `fastboot flashing unlock`
standard, et il n'existe aucun port postmarketOS/LineageOS pour ce modèle.
Un boot natif demande un appareil cible différent — voir `docs/ROADMAP.md`.

## Utilisation

```sh
./tools/setup-mac.sh          # installe colima + docker + qemu (une fois)
./desktop/build.sh            # -> out/pythagor-os-0.1-amd64.iso
./mobile/build-rootfs.sh      # -> out/pythagor-os-0.1-arm64-rootfs.tar.gz
./mobile/install-termux.sh    # pousse le rootfs sur le téléphone via adb
./tools/test-qemu.sh          # teste l'ISO sans graver
```

## Catalogue d'outils

PYTHAGOR OS embarque un catalogue d'outils organisé par catégorie (recon, web,
réseau, reversing, forensique, dev, crypto…), façon Kali/BlackArch mais
installable **à la demande** — on ne télécharge que ce qu'on veut.

```sh
pythagor-tools list                      # catégories : compte + taille estimée
pythagor-tools search nmap               # trouver un outil
pythagor-tools info web                  # détail d'une catégorie
pythagor-tools install recon-osint web   # installer des catégories
pythagor-tools install all               # tout installer
pythagor-enable-kali                     # débloquer les outils Kali-only (opt-in)
```

Les listes vivent dans `common/tools/lists/*.list` (Debian) et `*.kali.list`
(outils présents uniquement dans Kali). L'installation est **tolérante** : un
paquet introuvable est ignoré et signalé, jamais d'échec global.

> Sur le CAMON 30S : ~19 Go libres et ~130 Ko/s. Tout installer représente
> plusieurs Go et de longues heures de téléchargement — d'où l'installation par
> catégorie plutôt qu'en bloc.

## Versions

`0.1` — socle amorçable, branding, shell, catalogue d'outils.

Licence : GPL-3.0

