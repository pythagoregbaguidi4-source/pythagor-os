#!/data/data/com.termux/files/usr/bin/bash
# Installe le catalogue d'outils (pythagor-tools + listes) dans un rootfs
# PYTHAGOR OS déjà déployé, sans rebuild. Tourne dans Termux.
#
# Attend /sdcard/Download/pythagor-tools.tar.gz (bin + lists/).
set -eu

SRC=/sdcard/Download
R="${PYTHAGOR_ROOTFS:-$HOME/pythagor}"
[ -d "$R/etc" ] || { echo "rootfs introuvable dans $R" >&2; exit 1; }
[ -r "$SRC/pythagor-tools.tar.gz" ] || { echo "archive absente : $SRC/pythagor-tools.tar.gz" >&2; exit 1; }

echo "=== catalogue d'outils PYTHAGOR OS ==="
tmp="$R/tmp/pt-stage"; rm -rf "$tmp"; mkdir -p "$tmp"
tar -xzf "$SRC/pythagor-tools.tar.gz" -C "$tmp"

install -Dm755 "$tmp/pythagor-tools"       "$R/usr/local/bin/pythagor-tools"
install -Dm755 "$tmp/pythagor-enable-kali" "$R/usr/local/bin/pythagor-enable-kali"
mkdir -p "$R/usr/local/share/pythagor/tools"
cp "$tmp"/lists/*.list "$R/usr/local/share/pythagor/tools/"
rm -rf "$tmp"

n=$(find "$R/usr/local/share/pythagor/tools" -name '*.list' | wc -l | tr -d ' ')
echo "✔ catalogue installé ($n listes). Dans PYTHAGOR OS :  pythagor-tools list"
