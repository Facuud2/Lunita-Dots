#!/usr/bin/env bash

# Directorio de capturas
TARGET_DIR="${HOME}/Imagenes/Capturas de pantalla"
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
