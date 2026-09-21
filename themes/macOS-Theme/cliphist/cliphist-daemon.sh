#!/usr/bin/env bash
# ==============================================================================
# cliphist-daemon.sh - Demonio de Portapapeles con Auto-purga al 95% de Capacidad
# Lunita-Dots / Arch Linux
# ==============================================================================

set -euo pipefail

DB_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist"
mkdir -p "$DB_DIR"
PID_FILE="$DB_DIR/daemon.pid"
THRESHOLD=95
TARGET_THRESHOLD=88
BATCH_SIZE=200

# Función para verificar el porcentaje de ocupación del disco
get_disk_usage() {
    df -P "$DB_DIR" | awk 'NR==2 {gsub("%",""); print $5}'
}

# Función para purgar los elementos más antiguos si se alcanza el umbral
prune_if_needed() {
    local usage
    usage=$(get_disk_usage)
    
    if [ "$usage" -ge "$THRESHOLD" ]; then
        echo "[cliphist-daemon] Alerta: Ocupación de disco en ${usage}% (>= ${THRESHOLD}%)." >&2
        echo "[cliphist-daemon] Purgando los elementos más antiguos del historial..." >&2
        
        while [ "$usage" -ge "$TARGET_THRESHOLD" ]; do
            local count
            count=$(cliphist list | wc -l)
            if [ "$count" -eq 0 ]; then
                echo "[cliphist-daemon] Historial vacío, no hay más elementos para purgar." >&2
                break
            fi
            
            # cliphist list muestra el más nuevo arriba y el más antiguo al final (tail)
            cliphist list | tail -n "$BATCH_SIZE" | cliphist delete || true
            
            local new_usage
            new_usage=$(get_disk_usage)
            if [ "$new_usage" -eq "$usage" ]; then
                # Si el disco sigue saturado por otros archivos ajenos a cliphist, no entrar en loop infinito
                echo "[cliphist-daemon] Advertencia: Se eliminaron registros pero el disco general continúa al ${new_usage}%." >&2
                break
            fi
            usage="$new_usage"
        done
        echo "[cliphist-daemon] Purga finalizada. Uso actual: ${usage}%." >&2
    fi
}

# Comprobación directa vía argumento
case "${1:-start}" in
    --check-capacity)
        echo "Directorio de base de datos: $DB_DIR"
        echo "Uso actual del disco: $(get_disk_usage)%"
        echo "Total de elementos en historial: $(cliphist list | wc -l)"
        prune_if_needed
        exit 0
        ;;
    --status)
        echo "--- Estado de Cliphist ---"
        echo "Uso de disco: $(get_disk_usage)%"
        echo "Elementos almacenados: $(cliphist list | wc -l)"
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "Demonio: Activo (PID: $(cat "$PID_FILE"))"
        else
            echo "Demonio: Inactivo"
        fi
        exit 0
        ;;
    --stop)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            if kill -0 "$PID" 2>/dev/null; then
                kill -- -"$PID" 2>/dev/null || kill "$PID" 2>/dev/null || true
            fi
            rm -f "$PID_FILE"
        fi
        # Limpiar historial de portapapeles al apagar o detener
        cliphist wipe 2>/dev/null || true
        rm -f "$DB_DIR/timestamps.tsv" 2>/dev/null || true
        echo "[cliphist-daemon] Demonio detenido e historial purgado."
        exit 0
        ;;
    start|--start)
        # Continuar con el bucle del demonio
        ;;
    *)
        echo "Uso: $0 {start|--status|--check-capacity|--stop}"
        exit 1
        ;;
esac

# Evitar instancias duplicadas
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "[cliphist-daemon] Ya existe una instancia ejecutándose con PID $OLD_PID"
        exit 0
    fi
fi

echo $$ > "$PID_FILE"

# Limpiar historial de sesiones anteriores automáticamente al iniciar el PC / sesión
cliphist wipe 2>/dev/null || true
rm -f "$DB_DIR/timestamps.tsv" 2>/dev/null || true

cleanup() {
    trap - SIGINT SIGTERM EXIT
    echo "[cliphist-daemon] Terminando procesos observadores y purgando historial..."
    rm -f "$PID_FILE"
    [ -n "${PID_TEXT:-}" ] && kill "$PID_TEXT" 2>/dev/null || true
    [ -n "${PID_IMG:-}" ] && kill "$PID_IMG" 2>/dev/null || true
    # Limpiar historial al apagar o reiniciar la PC
    cliphist wipe 2>/dev/null || true
    rm -f "$DB_DIR/timestamps.tsv" 2>/dev/null || true
    exit 0
}
trap cleanup SIGINT SIGTERM EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Observador para textos normales y enriquecidos
wl-paste --watch "$SCRIPT_DIR/store-wrapper.sh" &
PID_TEXT=$!

# 2. Observador para imágenes binarias (capturas de pantalla, fotos)
wl-paste --type image --watch "$SCRIPT_DIR/store-wrapper.sh" &
PID_IMG=$!

echo "[cliphist-daemon] Historial reiniciado. Observadores de texto (PID $PID_TEXT) e imagen (PID $PID_IMG) iniciados."

# 3. Bucle de monitoreo continuo de capacidad (cada 30 segundos)
while true; do
    prune_if_needed
    sleep 30
done
