#!/usr/bin/env bash
# PYTHAGOR OS — édition PC : construit un ISO hybride (BIOS + UEFI, live USB).
# live-build tourne obligatoirement sous Linux avec root -> conteneur Debian.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../VERSION
. "$ROOT/VERSION"
OUT="$ROOT/out"
mkdir -p "$OUT"

command -v docker >/dev/null || { echo "docker absent — lance ./tools/setup-mac.sh"; exit 1; }

echo "== PYTHAGOR OS $PYTHAGOR_VERSION — édition PC / amd64 =="

docker run --rm --privileged \
    -v "$ROOT:/src:ro" -v "$OUT:/out" \
    -w /build \
    debian:bookworm bash -euxo pipefail -c '
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y --no-install-recommends live-build xorriso isolinux syslinux-common

    mkdir -p /build && cd /build
    lb config noauto \
        --distribution bookworm \
        --architectures amd64 \
        --archive-areas "main contrib non-free non-free-firmware" \
        --binary-images iso-hybrid \
        --debian-installer live \
        --iso-application "PYTHAGOR OS" \
        --iso-publisher "PYTHAGOR OS" \
        --iso-volume "PYTHAGOR_OS_0.1" \
        --bootappend-live "boot=live components quiet splash username=pythagor hostname=pythagor locales=fr_FR.UTF-8 keyboard-layouts=fr"

    # --- liste des paquets (commentaires filtrés) ---
    mkdir -p config/package-lists config/includes.chroot/tmp/pythagor-branding config/hooks/normal
    grep -hEv "^\s*(#|$)" /src/common/packages.list /src/common/packages-desktop.list \
        > config/package-lists/pythagor.list.chroot

    # --- branding embarqué puis appliqué par un hook ---
    cp /src/branding/os-release /src/branding/motd config/includes.chroot/tmp/pythagor-branding/
    cp /src/common/apply-branding.sh config/hooks/normal/0100-pythagor-branding.hook.chroot
    chmod +x config/hooks/normal/0100-pythagor-branding.hook.chroot

    # --- catalogue d'outils embarqué (installé par le même hook) ---
    mkdir -p config/includes.chroot/tmp/pythagor-tools/lists
    cp /src/common/tools/pythagor-tools /src/common/tools/pythagor-enable-kali config/includes.chroot/tmp/pythagor-tools/
    cp /src/common/tools/lists/*.list config/includes.chroot/tmp/pythagor-tools/lists/ 2>/dev/null || true

    lb build
    cp -v live-image-amd64.hybrid.iso /out/pythagor-os-0.1-amd64.iso
'

echo
echo "✔ $OUT/pythagor-os-$PYTHAGOR_VERSION-amd64.iso"
echo
echo "  Tester   : ./tools/test-qemu.sh"
echo "  Graver   : diskutil list                       # repérer /dev/diskN de la clé"
echo "             diskutil unmountDisk /dev/diskN"
echo "             sudo dd if=$OUT/pythagor-os-$PYTHAGOR_VERSION-amd64.iso of=/dev/rdiskN bs=4m status=progress"
