#!/usr/bin/env bash
# Prépare macOS pour construire PYTHAGOR OS.
# live-build exige Linux + root : on passe donc par une VM Linux (colima) + docker.
set -euo pipefail

echo "== PYTHAGOR OS : préparation de l'hôte macOS =="

command -v brew >/dev/null || { echo "Homebrew requis : https://brew.sh"; exit 1; }

# --- espace disque : le point critique sur cette machine ---
FREE_GB=$(df -g / | awk 'NR==2{print $4}')
echo "Espace libre : ${FREE_GB} Go"
if [ "$FREE_GB" -lt 30 ]; then
    cat <<EOF

  ⚠  ${FREE_GB} Go libres — insuffisant.
     Un build ISO consomme ~20-25 Go de fichiers temporaires.

     Trois options :
       1. Libérer de la place (viser 40 Go libres)
       2. Brancher un SSD externe et y placer colima :
            export COLIMA_HOME=/Volumes/MON_SSD/colima
       3. Ne rien installer ici : builder dans GitHub Actions
            (voir .github/workflows/build.yml — runner de 14 Go, gratuit)

EOF
    read -rp "Continuer quand même ? [o/N] " a
    [ "${a:-n}" = "o" ] || exit 1
fi

echo "-- installation colima / docker / qemu"
brew install colima docker qemu

echo "-- démarrage de la VM de build (4 Go RAM, 60 Go disque extensible)"
colima start --cpu 4 --memory 4 --disk 60 --arch x86_64 || colima start

echo "-- activation binfmt (permet de builder de l'arm64 depuis x86_64)"
docker run --privileged --rm tonistiigi/binfmt --install arm64

echo
echo "✔ Prêt.  ./desktop/build.sh   puis   ./mobile/build-rootfs.sh"
