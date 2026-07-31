#!/bin/sh
# Applique l'identité PYTHAGOR OS dans un rootfs déjà monté.
# Exécuté DANS le chroot (live-build hook, ou chroot manuel côté mobile).
# Volontairement en /bin/sh POSIX : tourne aussi bien sous Debian que sous busybox.
set -e

echo "[branding] identité PYTHAGOR OS"

# --- identité système ---
# Sous Debian /etc/os-release est DÉJÀ un lien vers /usr/lib/os-release.
# Écrire dans l'un puis lier l'autre créerait une boucle de liens symboliques :
# on supprime les deux, on écrit le fichier réel, puis on refait le lien.
rm -f /etc/os-release /usr/lib/os-release
install -Dm644 /tmp/pythagor-branding/os-release /usr/lib/os-release
ln -sf ../usr/lib/os-release /etc/os-release

echo "pythagor" > /etc/hostname
cat > /etc/hosts <<'EOF'
127.0.0.1   localhost
127.0.1.1   pythagor
::1         localhost ip6-localhost ip6-loopback
EOF

# --- bannières ---
# Le fichier source contient des séquences \e littérales (les octets ESC bruts
# ne survivent pas à l'édition) : printf %b les convertit ici.
printf '%b' "$(cat /tmp/pythagor-branding/motd)" > /etc/motd
printf '\n' >> /etc/motd
printf 'PYTHAGOR OS 0.1 \\n \\l\n\n' > /etc/issue
cp /etc/issue /etc/issue.net

# --- invite de commande ---
cat > /etc/profile.d/50-pythagor.sh <<'EOF'
# Invite PYTHAGOR OS — cyan pour l'utilisateur, rouge pour root.
if [ -n "$BASH_VERSION" ]; then
    if [ "$(id -u)" -eq 0 ]; then
        PS1='\[\e[1;31m\]❯\[\e[0m\] \[\e[1;37m\]\w\[\e[0m\] # '
    else
        PS1='\[\e[1;36m\]❯\[\e[0m\] \[\e[1;37m\]\w\[\e[0m\] $ '
    fi
fi
export PYTHAGOR_OS=1
EOF

# Le motd n'est pas affiché par les shells non-login (proot, docker) : on force.
cat > /etc/profile.d/00-pythagor-motd.sh <<'EOF'
[ -t 1 ] && [ -z "$PYTHAGOR_MOTD_SHOWN" ] && {
    export PYTHAGOR_MOTD_SHOWN=1
    cat /etc/motd 2>/dev/null
}
EOF

# --- locale ---
sed -i 's/^# *\(fr_FR.UTF-8\)/\1/; s/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen >/dev/null 2>&1 || true
echo 'LANG=fr_FR.UTF-8' > /etc/default/locale

# --- catalogue d'outils (si présent) ---
if [ -d /tmp/pythagor-tools ]; then
    echo "[branding] installation du catalogue d'outils"
    install -m755 /tmp/pythagor-tools/pythagor-tools      /usr/local/bin/pythagor-tools
    install -m755 /tmp/pythagor-tools/pythagor-enable-kali /usr/local/bin/pythagor-enable-kali
    mkdir -p /usr/local/share/pythagor/tools
    cp /tmp/pythagor-tools/lists/*.list /usr/local/share/pythagor/tools/ 2>/dev/null || true
fi

echo "[branding] terminé"
