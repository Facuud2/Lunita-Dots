#!/usr/bin/env bash
set -e

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="qylock-orbital"
TARGET="/usr/share/sddm/themes/${THEME_NAME}"

echo "=========================================="
echo " Instalando tema SDDM: ${THEME_NAME}"
echo "=========================================="

SUDO=""
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
fi

echo "[1/3] Copiando archivos a ${TARGET}..."
$SUDO mkdir -p "${TARGET}"
$SUDO cp -r "${THEME_DIR}"/* "${TARGET}/"

echo "[2/3] Configurando permisos..."
$SUDO chmod -R 755 "${TARGET}"

echo "[3/3] Activando tema en /etc/sddm.conf.d/theme.conf..."
$SUDO mkdir -p /etc/sddm.conf.d
$SUDO bash -c "cat << 'CONF' > /etc/sddm.conf.d/theme.conf
[Theme]
Current=${THEME_NAME}
CONF"

echo "=========================================="
echo " ¡Tema instalado y activado exitosamente!"
echo "=========================================="
