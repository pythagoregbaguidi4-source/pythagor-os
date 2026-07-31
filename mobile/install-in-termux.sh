#!/data/data/com.termux/files/usr/bin/bash
# Installe PYTHAGOR OS mobile depuis Termux.
# Poussé dans /sdcard/Download par mobile/install-termux.sh, puis lancé par :
#     bash /sdcard/Download/install-pythagor.sh
#
# Un script plutôt que des commandes tapées une par une : le clavier virtuel
# piloté par `adb input text` casse sur les caractères spéciaux ($, ~, &&).
set -eu

SRC=/sdcard/Download
ROOTFS="$HOME/pythagor"

echo "=== PYTHAGOR OS — installation mobile ==="

if [ ! -r "$SRC/pythagor-rootfs.tar.gz" ]; then
    echo "ERREUR : $SRC/pythagor-rootfs.tar.gz illisible." >&2
    echo "Lance 'termux-setup-storage' et accepte la demande, puis réessaie." >&2
    exit 1
fi

echo "--- [1/4] dépendances"
pkg install -y proot tar >/dev/null

echo "--- [2/4] extraction (quelques minutes, ~500 Mo)"
rm -rf "$ROOTFS"
mkdir -p "$ROOTFS"
cd "$ROOTFS"
# --link2symlink : Android interdit les liens durs, proot les convertit.
proot --link2symlink tar -xzf "$SRC/pythagor-rootfs.tar.gz"

echo "--- [3/4] lanceur"
install -m755 "$SRC/pythagor" "$PREFIX/bin/pythagor"

echo "--- [4/4] vérification"
grep -m1 PRETTY_NAME "$ROOTFS/usr/lib/os-release"
echo "taille : $(du -sh "$ROOTFS" | cut -f1)"

cat <<'EOF'

✔ PYTHAGOR OS installé.  Lance-le avec :

    pythagor

EOF
