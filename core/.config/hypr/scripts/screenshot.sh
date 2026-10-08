#!/usr/bin/env bash

# Directorio de capturas (resolución portátil con xdg-user-dir)
PICTURES_DIR=""
if command -v xdg-user-dir >/dev/null 2>&1; then
    PICTURES_DIR=$(xdg-user-dir PICTURES 2>/dev/null)
fi
if [ -z "$PICTURES_DIR" ] || [ ! -d "$PICTURES_DIR" ]; then
    if [ -d "${HOME}/Imagenes" ]; then
        PICTURES_DIR="${HOME}/Imagenes"
    elif [ -d "${HOME}/Pictures" ]; then
        PICTURES_DIR="${HOME}/Pictures"
    else
        PICTURES_DIR="${HOME}/Imagenes"
    fi
fi
TARGET_DIR="${PICTURES_DIR}/Capturas de pantalla"
mkdir -p "$TARGET_DIR"

MODE="${1:-area}"
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
FILENAME="Captura_${TIMESTAMP}.png"
FILEPATH="${TARGET_DIR}/${FILENAME}"

case "$MODE" in
    area)
        # Seleccionar geometría con slurp
        GEOM=$(slurp)
        # Si el usuario cancela (slurp retorna código de error o texto vacío), salir sin error
        if [ -z "$GEOM" ]; then
            exit 0
        fi
        grim -g "$GEOM" "$FILEPATH"
        ;;
    screen)
        # Captura de pantalla completa
        grim "$FILEPATH"
        ;;
    *)
        grim "$FILEPATH"
        ;;
esac

# Verificar que el archivo se creó correctamente
if [ -f "$FILEPATH" ]; then
    # Copiar al portapapeles
    wl-copy < "$FILEPATH"
    
    # Enviar notificación con icono de la captura
    notify-send -i "$FILEPATH" "Captura de pantalla" "Se guardó la captura" -a "Captura de pantalla"
fi
