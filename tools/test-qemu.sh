#!/usr/bin/env bash
# Démarre l'ISO PYTHAGOR OS dans QEMU — vérifier le boot sans graver de clé.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../VERSION
. "$ROOT/VERSION"
ISO="$ROOT/out/pythagor-os-$PYTHAGOR_VERSION-amd64.iso"

[ -f "$ISO" ] || { echo "ISO absent — lance d'abord ./desktop/build.sh"; exit 1; }
command -v qemu-system-x86_64 >/dev/null || { echo "qemu absent : brew install qemu"; exit 1; }

# 3 Go : la machine n'en a que 8 au total, on garde de la marge pour macOS.
exec qemu-system-x86_64 \
    -m 3072 -smp 2 \
    -cdrom "$ISO" \
    -boot d \
    -vga virtio -display default,show-cursor=on \
    -netdev user,id=n0 -device virtio-net,netdev=n0
