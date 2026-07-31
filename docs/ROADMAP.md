# Feuille de route PYTHAGOR OS

## 0.1 — socle

- [x] Recette unique amd64 / arm64
- [x] Branding : `os-release`, motd, invite, locale fr
- [x] ISO PC live (BIOS + UEFI)
- [x] rootfs mobile arm64 — build CI vérifié le 2026-07-30 (4m02s, 147 Mo,
      aarch64 confirmé, sha256 OK, `os-release` et motd validés dans l'archive)
- [ ] Premier lancement vérifié sur le CAMON 30S — *en attente : téléphone à rebrancher*
- [ ] Build ISO amd64 (`gh workflow run pythagor.yml -f cible=desktop`)
- [ ] Premier boot vérifié en QEMU

## 0.2 — identité visuelle

- [ ] Thème Plymouth (écran d'amorçage) avec le nom PYTHAGOR OS
- [ ] Fond d'écran + thème GTK
- [ ] Thème GRUB
- [ ] Métapaquet `pythagor-desktop` au lieu de listes brutes

## 0.3 — installable

- [ ] Calamares : installer PYTHAGOR OS sur le disque, pas seulement en live
- [ ] Dépôt APT dédié pour livrer les mises à jour
- [ ] Signature GPG des paquets

## 1.0 — Boot natif sur Android

C'est l'objectif final, et c'est le morceau difficile. Il ne dépend pas du code
de ce dépôt mais du **matériel cible**.

### Ce qui bloque sur le TECNO CAMON 30S

| Prérequis | État |
|---|---|
| Bootloader déverrouillable | non exposé par Transsion en `fastboot flashing unlock` |
| Sources kernel de l'appareil | non publiées (obligation GPL non honorée) |
| Port postmarketOS / LineageOS | inexistant pour ce modèle |
| Arbre de périphériques (DTB) | à rétro-concevoir intégralement |

Conclusion : **ce téléphone ne peut pas booter PYTHAGOR OS nativement.**
L'édition proot reste la seule voie sur cet appareil — et elle fonctionne.

### Voies réalistes pour un boot natif

1. **Appareil supporté par postmarketOS** — c'est la route la plus courte.
   Les Pixel, OnePlus, Xiaomi (Redmi Note surtout) et Fairphone d'occasion sont
   bon marché et souvent déjà portés. Le rootfs arm64 de ce dépôt s'y branche
   quasiment tel quel.

2. **GSI (Generic System Image)** — si un appareil est Treble-compatible, une
   image système générique s'y flashe sans port spécifique. Reste de l'Android,
   pas du Linux : moins « PYTHAGOR OS », mais brandable.

3. **Single-board computer** (Raspberry Pi, PinePhone) — arm64, entièrement
   documenté, aucun bootloader verrouillé. Le meilleur terrain d'essai pour
   valider l'image bootable avant de viser un téléphone.

### Recommandation

Valider la chaîne complète sur un Raspberry Pi ou un appareil postmarketOS
avant d'investir dans le portage d'un appareil verrouillé. Le travail fait ici
(rootfs, branding, paquets) est déjà réutilisable à 100 % sur ces cibles.

## Hors périmètre

Construire un ROM AOSP/LineageOS complet : 250 Go de disque et 16 Go de RAM
minimum. Impossible sur la machine actuelle (8 Go RAM, 9 Go libres) et sans
objet tant qu'aucun appareil déverrouillable n'est disponible.
