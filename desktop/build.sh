#!/usr/bin/env bash
# PYTHAGOR OS — édition PC : construit un ISO live hybride (BIOS + UEFI, USB).
# live-build exige Linux + root -> conteneur Debian. La logique est dans
# desktop/build-in-container.sh (évite l'enfer des guillemets).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../VERSION
. "$ROOT/VERSION"
OUT="$ROOT/out"
mkdir -p "$OUT"

command -v docker >/dev/null || { echo "docker absent — lance ./tools/setup-mac.sh"; exit 1; }

echo "== PYTHAGOR OS $PYTHAGOR_VERSION — édition PC / amd64 (GNOME macOS) =="

docker run --rm --privileged \
    -v "$ROOT:/src:ro" -v "$OUT:/out" \
    debian:bookworm bash /src/desktop/build-in-container.sh

echo
echo "✔ $OUT/pythagor-os-$PYTHAGOR_VERSION-amd64.iso"
echo
echo "  Tester   : ./tools/test-qemu.sh"
echo "  Graver   : diskutil list                       # repérer /dev/diskN de la clé"
echo "             diskutil unmountDisk /dev/diskN"
echo "             sudo dd if=$OUT/pythagor-os-$PYTHAGOR_VERSION-amd64.iso of=/dev/rdiskN bs=4m status=progress"
