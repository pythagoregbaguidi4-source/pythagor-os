#!/usr/bin/env bash
# PYTHAGOR OS — logique de build du rootfs arm64, exécutée DANS le conteneur.
# Fichier séparé (comme desktop/build-in-container.sh) : évite l'enfer des
# guillemets d'un heredoc single-quoted (une apostrophe le casse).
set -euxo pipefail

. /src/VERSION
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y --no-install-recommends \
    $(grep -hEv '^\s*(#|$)' /src/common/packages.list | tr '\n' ' ')

mkdir -p /tmp/pythagor-branding
cp /src/branding/os-release /src/branding/motd /tmp/pythagor-branding/

# catalogue d'outils + système de MAJ (installes par apply-branding.sh)
mkdir -p /tmp/pythagor-tools/lists
cp /src/common/tools/pythagor-tools /src/common/tools/pythagor-enable-kali \
   /src/common/tools/help-me /src/common/tools/pythagor-update \
   /src/common/tools/pythagor-update-notify /src/common/tools/profile-update-check.sh \
   /tmp/pythagor-tools/
cp /src/common/tools/lists/*.list /tmp/pythagor-tools/lists/ 2>/dev/null || true

# cachet de version (git vient de packages.list)
git config --global --add safe.directory /src 2>/dev/null || true
( git -C /src rev-parse --short HEAD 2>/dev/null || echo unknown ) > /etc/pythagor-version

sh /src/common/apply-branding.sh

# proot fournit son propre /proc, /sys, /dev : on ne les embarque pas.
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/pythagor-branding

tar -czf /out/rootfs.tmp.tar.gz \
    --exclude=./proc/* --exclude=./sys/* --exclude=./dev/* \
    --exclude=./out --exclude=./src \
    --numeric-owner -C / .
