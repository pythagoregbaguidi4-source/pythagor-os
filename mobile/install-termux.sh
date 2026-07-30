#!/usr/bin/env bash
# Pousse PYTHAGOR OS mobile sur le téléphone via adb.
#
# Contrainte : adb ne peut PAS écrire dans le répertoire privé de Termux sur un
# appareil non rooté. On dépose donc dans /sdcard/Download, et Termux va y lire.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../VERSION
. "$ROOT/VERSION"
TARBALL="$ROOT/out/pythagor-os-$PYTHAGOR_VERSION-arm64-rootfs.tar.gz"

[ -f "$TARBALL" ] || { echo "rootfs absent — lance d'abord ./mobile/build-rootfs.sh"; exit 1; }
adb get-state >/dev/null 2>&1 || { echo "aucun appareil adb connecté"; exit 1; }

echo "== envoi vers /sdcard/Download ($(du -h "$TARBALL" | cut -f1)) =="
adb push "$TARBALL" /sdcard/Download/pythagor-rootfs.tar.gz
adb push "$ROOT/mobile/pythagor" /sdcard/Download/pythagor

cat <<'EOF'

✔ Fichiers déposés. Dans Termux, colle ceci (une seule fois) :

  pkg install -y proot tar
  termux-setup-storage
  mkdir -p ~/pythagor && cd ~/pythagor
  proot --link2symlink tar -xzf /sdcard/Download/pythagor-rootfs.tar.gz
  install -m755 /sdcard/Download/pythagor $PREFIX/bin/pythagor

Puis, à chaque fois :

  pythagor

EOF
