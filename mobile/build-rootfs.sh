#!/usr/bin/env bash
# PYTHAGOR OS — édition mobile : rootfs arm64.
# Même branding et mêmes paquets que l'édition PC, seule l'architecture change.
#
# Ce tarball sert deux usages :
#   - aujourd'hui : proot dans Termux, sans root, sur le CAMON 30S
#   - plus tard   : contenu de la partition system d'une image bootable
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../VERSION
. "$ROOT/VERSION"
OUT="$ROOT/out"
TARBALL="$OUT/pythagor-os-$PYTHAGOR_VERSION-arm64-rootfs.tar.gz"
mkdir -p "$OUT"

command -v docker >/dev/null || { echo "docker absent — lance ./tools/setup-mac.sh"; exit 1; }

echo "== PYTHAGOR OS $PYTHAGOR_VERSION ($PYTHAGOR_CODENAME) — édition mobile / arm64 =="

# --platform arm64 : émulé via binfmt/qemu, installé par setup-mac.sh
docker run --rm --privileged --platform linux/arm64 \
    -v "$ROOT:/src:ro" -v "$OUT:/out" \
    debian:bookworm bash -euxo pipefail -c '
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y --no-install-recommends \
        $(grep -hEv "^\s*(#|$)" /src/common/packages.list | tr "\n" " ")

    mkdir -p /tmp/pythagor-branding
    cp /src/branding/os-release /src/branding/motd /tmp/pythagor-branding/
    sh /src/common/apply-branding.sh

    # proot fournit son propre /proc, /sys, /dev : on ne les embarque pas.
    apt-get clean
    rm -rf /var/lib/apt/lists/* /tmp/pythagor-branding

    tar -czf /out/rootfs.tmp.tar.gz \
        --exclude=./proc/* --exclude=./sys/* --exclude=./dev/* \
        --exclude=./out --exclude=./src \
        --numeric-owner -C / .
'

mv "$OUT/rootfs.tmp.tar.gz" "$TARBALL"

# sha256sum sous Linux (CI), shasum sous macOS.
if command -v sha256sum >/dev/null; then
    (cd "$OUT" && sha256sum "$(basename "$TARBALL")") | tee "$TARBALL.sha256"
else
    (cd "$OUT" && shasum -a 256 "$(basename "$TARBALL")") | tee "$TARBALL.sha256"
fi

echo
echo "✔ $TARBALL  ($(du -h "$TARBALL" | cut -f1))"
echo "  Installer sur le téléphone : ./mobile/install-termux.sh"
