#!/bin/bash
# apply-pythagor.sh — applique branding + outils + thème à un système PYTHAGOR OS.
# IDEMPOTENT. Utilisé par `pythagor-update` sur un système BOOTÉ (installé ou
# persistant). Lit ses données depuis $SRC (racine du dépôt cloné).
#
#   sudo apply-pythagor.sh [SRC]        (SRC défaut : /opt/pythagor-os)
#
# NB : le BUILD de l'ISO, lui, passe par les hooks live-build (apply-branding +
# 9000..9900) ; ce script est la voie RUNTIME. Les deux lisent les mêmes fichiers
# de données (branding/, common/tools/, dconf) — une modif poussée sur le dépôt
# arrive par ici SANS reconstruire l'ISO.
set -u

SRC="${1:-/opt/pythagor-os}"
log(){ echo "[apply-pythagor] $*"; }

[ "$(id -u)" -eq 0 ] || { echo "doit être lancé en root (sudo)"; exit 1; }
[ -d "$SRC" ] || { echo "sources introuvables : $SRC"; exit 1; }
export DEBIAN_FRONTEND=noninteractive HOME=/root USER=root GIT_TERMINAL_PROMPT=0

# ---------------------------------------------------------------- branding ----
if [ -f "$SRC/branding/os-release" ]; then
    log "branding (os-release, motd)"
    rm -f /etc/os-release /usr/lib/os-release
    install -Dm644 "$SRC/branding/os-release" /usr/lib/os-release
    ln -sf ../usr/lib/os-release /etc/os-release
fi
[ -f "$SRC/branding/motd" ] && printf '%b\n' "$(cat "$SRC/branding/motd")" > /etc/motd

# ------------------------------------------------------------------- outils ---
if [ -d "$SRC/common/tools" ]; then
    log "catalogue d'outils + commandes"
    for c in pythagor-tools pythagor-enable-kali help-me pythagor-update; do
        [ -f "$SRC/common/tools/$c" ] && install -Dm755 "$SRC/common/tools/$c" "/usr/local/bin/$c"
    done
    mkdir -p /usr/local/share/pythagor/tools
    cp "$SRC/common/tools/lists/"*.list /usr/local/share/pythagor/tools/ 2>/dev/null || true
fi

# --------------------------------------------------- bureau GNOME (si présent) -
if [ -d /usr/share/gnome-shell ] || command -v gnome-shell >/dev/null 2>&1; then
    log "bureau GNOME : deps"
    apt-get install -y --no-install-recommends \
        git sassc libxml2-utils libglib2.0-dev-bin papirus-icon-theme \
        gnome-shell-extension-dashtodock >/dev/null 2>&1 || true

    WORK="$(mktemp -d)"

    # verre : blur-my-shell v47 (si absent)
    BMS=/usr/share/gnome-shell/extensions/blur-my-shell@aunetx
    if [ ! -f "$BMS/metadata.json" ]; then
        log "installation blur-my-shell v47"
        if git clone --depth 1 --branch v47 https://github.com/aunetx/blur-my-shell.git "$WORK/bms" >/dev/null 2>&1; then
            mkdir -p "$BMS/schemas"
            cp -a "$WORK/bms/src/." "$BMS/" 2>/dev/null || true
            cp -a "$WORK/bms/metadata.json" "$BMS/metadata.json" 2>/dev/null || true
            [ -d "$WORK/bms/resources/ui" ] && cp -a "$WORK/bms/resources/ui" "$BMS/ui" 2>/dev/null || true
            cp -a "$WORK/bms/schemas/"*.gschema.xml "$BMS/schemas/" 2>/dev/null || true
            glib-compile-schemas "$BMS/schemas/" 2>/dev/null || true
        fi
    fi

    # thème Graphite-teal-Dark (si absent) — mêmes correctifs chroot que le build
    if [ ! -d /usr/share/themes/Graphite-teal-Dark ]; then
        log "installation thème Graphite-teal-Dark"
        if git clone --depth 1 https://github.com/vinceliuice/Graphite-gtk-theme.git "$WORK/graphite" >/dev/null 2>&1; then
            ( cd "$WORK/graphite" && bash ./install.sh --dest /usr/share/themes -t teal -c dark --silent-mode ) >/dev/null 2>&1 \
                || log "ATTENTION : install Graphite en échec (thème par défaut conservé)"
        fi
    fi

    # réglages dconf (thème, icônes, dock, verre…)
    if [ -f "$SRC/branding/gnome/dconf/00-pythagor" ]; then
        log "réglages GNOME (dconf)"
        install -Dm644 "$SRC/branding/gnome/dconf/00-pythagor"  /etc/dconf/db/local.d/00-pythagor
        install -Dm644 "$SRC/branding/gnome/dconf/profile-user" /etc/dconf/profile/user
        dconf update 2>/dev/null || true
    fi
    rm -rf "$WORK"
fi

# ------------------------------------------------------------ cachet version --
if [ -d "$SRC/.git" ] && command -v git >/dev/null 2>&1; then
    git -C "$SRC" rev-parse --short HEAD > /etc/pythagor-version 2>/dev/null || true
fi

log "terminé. Version : $(cat /etc/pythagor-version 2>/dev/null || echo inconnue)"
