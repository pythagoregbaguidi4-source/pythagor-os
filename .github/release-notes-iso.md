ISO live bootable (BIOS + UEFI). Bureau GNOME identité **PYTHAGOR** : sombre, accent **cyan**, effet **verre** (thème Graphite-teal-Dark + blur-my-shell), icônes **Papirus-Dark**, dock. 114 outils cybersécu préinstallés. **Mises à jour en place via `pythagor-update`** — plus besoin de retélécharger l'ISO à chaque changement.

L'ISO dépasse la limite de 2 Gio par fichier de GitHub : il est **découpé en 2 parts**. Reconstitue-le puis grave-le.

**1. Télécharger** les 2 parts + la somme de contrôle :

- `pythagor-os-0.1-amd64.iso.part00`
- `pythagor-os-0.1-amd64.iso.part01`
- `pythagor-os-0.1-amd64.iso.sha256`

**2. Reconstituer** (Linux / macOS) :

```
cat pythagor-os-0.1-amd64.iso.part00 pythagor-os-0.1-amd64.iso.part01 > pythagor-os-0.1-amd64.iso
shasum -a 256 -c pythagor-os-0.1-amd64.iso.sha256   # doit afficher : OK
```

(sous Windows : `copy /b pythagor-os-0.1-amd64.iso.part00 + pythagor-os-0.1-amd64.iso.part01 pythagor-os-0.1-amd64.iso`)

**3. Graver** sur clé USB (≥ 4 Go). Sur macOS :

```
diskutil unmountDisk /dev/disk2
sudo dd if=pythagor-os-0.1-amd64.iso of=/dev/rdisk2 bs=4m status=progress
```
