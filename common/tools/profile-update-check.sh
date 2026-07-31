# /etc/profile.d/55-pythagor-update.sh — bannière « mise à jour dispo » au login.
# Léger : mis en cache (au plus 1 fois / 6 h) et avec un timeout réseau court.
if command -v pythagor-update >/dev/null 2>&1; then
    _pu_stamp=/tmp/.pythagor-update-checked
    _pu_now=$(date +%s 2>/dev/null || echo 0)
    _pu_last=$(stat -c %Y "$_pu_stamp" 2>/dev/null || echo 0)
    if [ $((_pu_now - _pu_last)) -gt 21600 ]; then
        : > "$_pu_stamp" 2>/dev/null || true
        if timeout 5 pythagor-update --check 2>/dev/null | grep -qi disponible; then
            printf '\033[1;36m→ Mise à jour PYTHAGOR OS disponible.\033[0m Lance : \033[1;36mpythagor-update\033[0m\n'
        fi
    fi
    unset _pu_stamp _pu_now _pu_last
fi
