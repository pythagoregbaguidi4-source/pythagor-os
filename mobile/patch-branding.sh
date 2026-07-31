#!/data/data/com.termux/files/usr/bin/bash
# Applique le nouveau branding + le lanceur corrigé sur un rootfs DÉJÀ installé,
# sans rebuild ni re-téléchargement. Tourne dans Termux (pas dans proot) :
# le rootfs est dans le home Termux, donc accessible en écriture directe.
#
# Poussé dans /sdcard/Download par adb, puis :  bash /sdcard/Download/patch-branding.sh
set -eu

SRC=/sdcard/Download
R="${PYTHAGOR_ROOTFS:-$HOME/pythagor}"

[ -d "$R/etc" ] || { echo "rootfs introuvable dans $R" >&2; exit 1; }

echo "=== patch PYTHAGOR OS ==="

echo "--- lanceur corrigé (unset LD_PRELOAD, PROOT_NO_SECCOMP)"
install -m755 "$SRC/pythagor" "$PREFIX/bin/pythagor"

echo "--- os-release (fichier réel derrière le lien /etc/os-release)"
install -Dm644 "$SRC/os-release" "$R/usr/lib/os-release"

echo "--- motd (séquences \\e converties)"
printf '%b\n' "$(cat "$SRC/motd")" > "$R/etc/motd"

echo "--- invite ❯"
cat > "$R/etc/profile.d/50-pythagor.sh" <<'EOF'
if [ -n "$BASH_VERSION" ]; then
    if [ "$(id -u)" -eq 0 ]; then
        PS1='\[\e[1;31m\]❯\[\e[0m\] \[\e[1;37m\]\w\[\e[0m\] # '
    else
        PS1='\[\e[1;36m\]❯\[\e[0m\] \[\e[1;37m\]\w\[\e[0m\] $ '
    fi
fi
export PYTHAGOR_OS=1
EOF

echo "--- vérification"
grep -m1 PRETTY_NAME "$R/usr/lib/os-release"
echo "✔ patch appliqué. Lance :  pythagor"
