#!/usr/bin/env bash
# PYTHAGOR OS — logique de build de l'ISO PC, exécutée DANS le conteneur Debian.
# Séparée de build.sh pour éviter l'enfer des guillemets (quotes/heredoc).
# Lecture : /src (dépôt, ro) — écriture : /build (scratch) et /out (artefact).
set -euxo pipefail

. /src/VERSION
export DEBIAN_FRONTEND=noninteractive

# --- sources avec toutes les zones (validation des paquets + lb build) ---
cat > /etc/apt/sources.list <<'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF
apt-get update -qq
apt-get install -y --no-install-recommends \
    live-build xorriso isolinux syslinux-common \
    imagemagick librsvg2-bin fonts-dejavu-core git

# /src est monté en lecture seule et appartient à un autre uid → git refuse
# ("dubious ownership"). On l'autorise pour lire le SHA du cachet de version.
git config --global --add safe.directory /src 2>/dev/null || true

mkdir -p /build && cd /build

# --- configuration live-build (ISO live hybride BIOS+UEFI) ---
lb config noauto \
    --mode debian \
    --distribution bookworm \
    --architectures amd64 \
    --archive-areas "main contrib non-free non-free-firmware" \
    --binary-images iso-hybrid \
    --debian-installer none \
    --iso-application "PYTHAGOR OS" \
    --iso-publisher "PYTHAGOR OS" \
    --iso-volume "PYTHAGOR_OS_${PYTHAGOR_VERSION}" \
    --bootappend-live "boot=live components quiet splash live-config.username=pythagor live-config.user-fullname=Pythagor live-config.hostname=pythagor"

# --- liste de paquets : concat + FILTRE (drop des noms inconnus, ex. skipfish) ---
mkdir -p config/package-lists
RAW=$(grep -hEv '^\s*(#|$)' \
        /src/common/packages.list \
        /src/common/packages-desktop.list \
        /src/desktop/essential-tools.list | sort -u)
: > config/package-lists/pythagor.list.chroot
for p in $RAW; do
    # apt-cache policy (pas 'show') : 'show' laisse passer les paquets simplement
    # RÉFÉRENCÉS mais non installables (ex. radare2 retiré de bookworm) → build KO.
    # On exige un vrai candidat d'installation (Candidate != (none)).
    cand=$(apt-cache policy "$p" 2>/dev/null | awk -F': ' '/Candidate:/{print $2}')
    if [ -n "$cand" ] && [ "$cand" != "(none)" ]; then
        echo "$p" >> config/package-lists/pythagor.list.chroot
    else
        echo "  [DROP] non installable, ignoré : $p" >&2
    fi
done
echo "== $(wc -l < config/package-lists/pythagor.list.chroot) paquets retenus =="

# --- branding de base (os-release, motd, catalogue d'outils) via hook 0100 ---
mkdir -p config/includes.chroot/tmp/pythagor-branding config/hooks/normal
cp /src/branding/os-release /src/branding/motd config/includes.chroot/tmp/pythagor-branding/
cp /src/common/apply-branding.sh config/hooks/normal/0100-pythagor-branding.hook.chroot
chmod +x config/hooks/normal/0100-pythagor-branding.hook.chroot

mkdir -p config/includes.chroot/tmp/pythagor-tools/lists
cp /src/common/tools/pythagor-tools /src/common/tools/pythagor-enable-kali \
   /src/common/tools/help-me /src/common/tools/pythagor-update \
   /src/common/tools/pythagor-update-notify /src/common/tools/profile-update-check.sh \
   config/includes.chroot/tmp/pythagor-tools/
cp /src/branding/gnome/pythagor-update-check.desktop config/includes.chroot/tmp/pythagor-tools/
cp /src/common/tools/lists/*.list config/includes.chroot/tmp/pythagor-tools/lists/ 2>/dev/null || true

# --- cachet de version (pour pythagor-update --check) ---
mkdir -p config/includes.chroot/etc
( git -C /src rev-parse --short HEAD 2>/dev/null || echo unknown ) \
    > config/includes.chroot/etc/pythagor-version

# --- fichiers GNOME / macOS (déposés tels quels dans l'image) ---
install -Dm644 /src/branding/gnome/gdm-daemon.conf    config/includes.chroot/etc/gdm3/daemon.conf
install -Dm644 /src/branding/gnome/dconf/00-pythagor  config/includes.chroot/etc/dconf/db/local.d/00-pythagor
install -Dm644 /src/branding/gnome/dconf/profile-user config/includes.chroot/etc/dconf/profile/user

# --- fond d'écran (SVG -> PNG) ---
mkdir -p config/includes.chroot/usr/share/backgrounds
convert -background none /src/branding/gnome/wallpaper.svg -resize 1920x1080 \
        config/includes.chroot/usr/share/backgrounds/pythagor.png

# --- thème Plymouth (script + assets) ---
PTH=config/includes.chroot/usr/share/plymouth/themes/pythagor
mkdir -p "$PTH"
cp /src/branding/plymouth/pythagor.plymouth "$PTH/"
cp /src/branding/plymouth/pythagor.script   "$PTH/"
convert -background none /src/branding/plymouth/logo.svg -resize 720x240 "$PTH/logo.png"
convert -size 8x8 xc:'#00d7d7' "$PTH/bar.png"

# --- hooks GNOME (9000..9900), après le hook de branding 0100 ---
cp /src/desktop/hooks/*.hook.chroot config/hooks/normal/
chmod +x config/hooks/normal/*.hook.chroot

# --- construction ---
lb build

cp -v live-image-amd64.hybrid.iso "/out/pythagor-os-${PYTHAGOR_VERSION}-amd64.iso"
echo "== ISO produit : /out/pythagor-os-${PYTHAGOR_VERSION}-amd64.iso =="
