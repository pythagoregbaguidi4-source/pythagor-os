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

for c in pythagor-tools pythagor-enable-kali help-me pythagor-update pythagor-update-notify; do
    [ -f "$tmp/$c" ] && install -Dm755 "$tmp/$c" "$R/usr/local/bin/$c"
done
# bannière MAJ au login (shell)
[ -f "$tmp/profile-update-check.sh" ] && \
    install -Dm644 "$tmp/profile-update-check.sh" "$R/etc/profile.d/55-pythagor-update.sh"
mkdir -p "$R/usr/local/share/pythagor/tools"
cp "$tmp"/lists/*.list "$R/usr/local/share/pythagor/tools/"
rm -rf "$tmp"

n=$(find "$R/usr/local/share/pythagor/tools" -name '*.list' | wc -l | tr -d ' ')
echo "✔ catalogue installé ($n listes). Dans PYTHAGOR OS :  pythagor-tools list"
