<div align="center">

```
 ___  _   _ _____ _  _   _    ___  ___  ___
| _ \| | | |_   _| || | /_\  / __|/ _ \| _ \
|  _/| |_| | | | | __ |/ _ \| (_ | (_) |   /
|_|   \___/  |_| |_||_/_/ \_\\___|\___/|_|_\
```

**PYTHAGOR OS** — la distribution Linux à mon image.
Sombre, accent cyan, effet verre. Une recette, deux éditions : **PC** et **Android**.

![Plateformes](https://img.shields.io/badge/plateformes-PC%20amd64%20%2B%20Android%20arm64-00bcd4?style=flat-square)
![Base](https://img.shields.io/badge/base-Debian%2012%20bookworm-a81d33?style=flat-square)
![Bureau](https://img.shields.io/badge/bureau-GNOME%20sombre%20cyan-00bcd4?style=flat-square)
![Licence](https://img.shields.io/badge/licence-GPL--3.0-blue?style=flat-square)

</div>

---

## C'est quoi

**PYTHAGOR OS** est ma distribution Linux personnelle, bâtie sur **Debian 12**.
Elle porte mon nom — **Pythagor** — et rien d'autre : *aucun rapport avec le
théorème de mathématiques*, aucune marque tierce. Une identité sobre et cohérente,
la même du démarrage au bureau.

Elle existe en **deux éditions issues d'une seule recette** :

| Édition | Format | Où | État |
|---|---|---|---|
| **PC** | ISO live hybride BIOS+UEFI (amd64) | clé USB, PC ancien ou récent, VirtualBox | ✅ livrée |
| **Mobile** | rootfs arm64 | Android via `proot` dans Termux (sans root) | ✅ fonctionne |

---

## 🎨 Identité visuelle *(matière pour le design)*

Le langage visuel de PYTHAGOR OS, à réutiliser tel quel pour tout travail de design
(logo, fond d'écran, écran « À propos », site…) :

| Élément | Choix |
|---|---|
| **Ambiance** | sombre, épurée, technique mais chaleureuse |
| **Accent** | **cyan / turquoise** (ANSI `0;36`) — indicatif `#00BCD4` → `#2DD4BF` |
| **Fond** | gris très sombre / noir (thème **Graphite-Dark**) — indicatif `#1A1A1A` → `#202124` |
| **Effet signature** | **verre** (flou translucide, *blur-my-shell*) sur panneaux et dock |
| **Thème bureau** | **Graphite-teal-Dark** (GTK + shell + fenêtres) |
| **Icônes** | **Papirus-Dark** (surtout **pas** de style macOS) |
| **Invite shell** | chevron `❯` cyan (rouge en root) |
| **Wordmark** | `PYTHAGOR OS` en capitales, cyan sur fond sombre (voir l'ASCII ci-dessus) |
| **Ton** | sobre, direct, sans jargon inutile ; versions = simples numéros, pas de nom de code |

> **À faire côté design** : un logo distributeur pour l'écran *Paramètres → À propos*
> (aujourd'hui GNOME y montre encore son propre logo).

---

## 💻 Édition PC — installer

L'ISO est publiée en **Release GitHub**. Comme elle dépasse la limite de 2 Gio par
fichier, elle est **découpée en 2 parts** que l'on recolle avec `cat` (aucune
décompression). C'est un téléchargement **unique** : ensuite tout se met à jour
en place via `pythagor-update` (voir plus bas).

**➡️ Release : [`iso-0.1`](https://github.com/pythagoregbaguidi4-source/pythagor-os/releases/tag/iso-0.1)**

**1. Télécharger** les 3 fichiers (même dossier) :
`pythagor-os-0.1-amd64.iso.part00`, `…part01`, `…iso.sha256`

**2. Reconstituer et vérifier** (Linux / macOS) :

```sh
cat pythagor-os-0.1-amd64.iso.part00 pythagor-os-0.1-amd64.iso.part01 > pythagor-os-0.1-amd64.iso
shasum -a 256 -c pythagor-os-0.1-amd64.iso.sha256      # doit afficher : OK
```

*(Windows : `copy /b …part00 + …part01 pythagor-os-0.1-amd64.iso`)*

**3a. Tester sans rien graver — VirtualBox** : nouvelle VM *Linux / Debian 64-bit*,
4 Go RAM, contrôleur graphique **VMSVGA** + 128 Mo, l'ISO en lecteur optique, boot
sur le CD.

**3b. Graver sur clé USB** (≥ 4 Go, **efface la clé**) :

```sh
# macOS  (remplace diskN par ta clé — vérifie avec : diskutil list)
diskutil unmountDisk /dev/disk2 && sudo dd if=pythagor-os-0.1-amd64.iso of=/dev/rdisk2 bs=4m

# Linux  (remplace sdX par ta clé — vérifie avec : lsblk)
sudo dd if=pythagor-os-0.1-amd64.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

Puis boote dessus (menu de démarrage : F12 / F9 / Échap selon la marque).

---

## 📱 Édition mobile — Android sans root

Un rootfs **arm64** tourne dans **Termux** via `proot` (aucun root, aucun
déverrouillage requis). Une fois déployé, on lance simplement :

```sh
pythagor
```

Le **même** rootfs pourra être injecté dans une image bootable le jour où un
appareil au bootloader déverrouillable est disponible — rien à refaire. Le boot
natif est **bloqué** sur le CAMON 30S (bootloader verrouillé, sources kernel non
publiées par Transsion) : voir [`docs/ROADMAP.md`](docs/ROADMAP.md).

---

## 🔄 Mises à jour — sans retélécharger l'ISO

Le cœur de PYTHAGOR OS : l'ISO n'est que l'**installation initiale**. Ensuite,
thème / outils / identité se mettent à jour **par le réseau, en quelques Mo**,
depuis ce dépôt public — **jamais** un nouvel ISO de 2 Go.

```sh
pythagor-update --check    # dit juste si une mise à jour est dispo (léger)
pythagor-update            # récupère (scripts+thèmes) et applique branding/thème/outils
```

Une **bannière** au login prévient quand une nouvelle version existe. Pour
distribuer un changement, il suffit de le **pousser sur ce dépôt** : toute
installation qui lance `pythagor-update` le récupère.

> **Persistance** : sur un **live USB** le système tourne depuis la RAM → les MAJ
> ne survivent pas au reboot (nature du live). **Installé sur disque** (ou en mobile
> `proot`, déjà persistant), les MAJ **restent**. L'installateur disque (Calamares)
> est un jalon à venir.

---

## 🛠️ Catalogue d'outils cybersécu

Un catalogue de **1409 outils** (21 catégories : recon, web, réseau, reversing,
forensique, crypto, dev…), façon Kali/BlackArch mais **installable à la demande** —
on ne télécharge que ce qu'on veut. Un noyau essentiel (~114 outils) est
**préinstallé** dans l'ISO.

```sh
help-me                                  # toute la notice de l'OS
pythagor-tools list                      # catégories : compte + taille estimée
pythagor-tools search nmap               # trouver un outil
pythagor-tools install recon-osint web   # installer des catégories
pythagor-tools install all               # tout installer
pythagor-enable-kali                     # débloquer les outils Kali-only (opt-in)
```

Les listes vivent dans `common/tools/lists/*.list` (Debian) et `*.kali.list`.
L'installation est **tolérante** : un paquet introuvable est ignoré et signalé,
jamais d'échec global.

---

## 🏗️ Construire soi-même

Le build se fait en **GitHub Actions** (live-build exige Linux + root ; un ISO
réclame 20-25 Go, impossible nativement sur le Mac) :

```sh
gh workflow run pythagor.yml -f cible=desktop     # ISO PC  (mobile | desktop | les-deux)
gh workflow run release.yml  -f run_id=<id_du_build>   # découpe + publie l'ISO en Release
```

Des scripts locaux existent aussi (`tools/setup-mac.sh`, `desktop/build.sh`,
`mobile/build-rootfs.sh`, `tools/test-qemu.sh`) mais la CI est la voie supportée.

---

## 📂 Structure du dépôt

```
common/     branding + paquets + config + outils + apply-pythagor.sh   (partagé)
desktop/    build ISO amd64 (live-build) + hooks (thème, plymouth, dconf)
mobile/     build rootfs arm64 + intégration Termux/proot
branding/   os-release, motd, thème GNOME (dconf), plymouth, fond d'écran
.github/    workflows CI : pythagor.yml (build) + release.yml (publication)
docs/       ROADMAP et notes
```

**Architecture** : un seul jeu `common/` (branding + paquets + config), décliné en
deux cibles par simple changement d'architecture `debootstrap` (amd64 → ISO,
arm64 → rootfs).

---

## Versions & licence

`0.1` — socle amorçable : branding, bureau GNOME sombre/cyan/verre, catalogue
d'outils, mises à jour en place.

Licence **GPL-3.0** · Auteur : **Pythagor**
