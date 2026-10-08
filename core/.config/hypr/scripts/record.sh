#!/usr/bin/env bash

TARGET_DIR="${HOME}/Videos/Grabaciones de pantalla"
mkdir -p "$TARGET_DIR"

TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
FILENAME="Grabacion_${TIMESTAMP}.mp4"
FILEPATH="${TARGET_DIR}/${FILENAME}"

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/ags/recording_config.json"

# Función para limpiar cualquier módulo virtual de audio residual
cleanup_audio_modules() {
    pactl list modules short 2>/dev/null | grep wf_recorder_combined | awk '{print $1}' | while read -r id; do
        pactl unload-module "$id" 2>/dev/null || true
    done
}

# Función para detener grabación activa
stop_recording() {
    if pgrep -x wf-recorder >/dev/null 2>&1; then
        killall -s SIGINT wf-recorder
        # Esperar a que el proceso guarde los metadatos y finalice
        while pgrep -x wf-recorder >/dev/null 2>&1; do
            sleep 0.1
        done
    fi
    cleanup_audio_modules
    return 0
}

# Parsear argumentos y opciones
MODE=""
FLAG_SYS=""
FLAG_MIC=""

for arg in "$@"; do
    case "$arg" in
        area|screen|stop)
            MODE="$arg"
            ;;
        --sound|--audio-system|--sys)
            FLAG_SYS=true
            ;;
        --no-sound|--no-audio-system|--no-sys)
            FLAG_SYS=false
            ;;
        --mic|--audio-mic)
            FLAG_MIC=true
            ;;
        --no-mic|--no-audio-mic)
            FLAG_MIC=false
            ;;
    esac
done

MODE="${MODE:-area}"

# Si se pide detener explícitamente
if [ "$MODE" = "stop" ]; then
    stop_recording
    exit 0
fi

# Si ya hay una grabación en curso y se presiona un atajo de grabación, actúa como toggle (detiene)
if pgrep -x wf-recorder >/dev/null 2>&1; then
    stop_recording
    exit 0
fi

# Determinar estado de audio (por defecto desde config guardada si existe)
RECORD_SYS=false
RECORD_MIC=false

if [ -f "$CONFIG_FILE" ]; then
    if command -v jq >/dev/null 2>&1; then
        RECORD_SYS=$(jq -r '.systemAudio // false' "$CONFIG_FILE" 2>/dev/null || echo "false")
        RECORD_MIC=$(jq -r '.micAudio // false' "$CONFIG_FILE" 2>/dev/null || echo "false")
    else
        grep -qi '"systemAudio"[[:space:]]*:[[:space:]]*true' "$CONFIG_FILE" && RECORD_SYS=true
        grep -qi '"micAudio"[[:space:]]*:[[:space:]]*true' "$CONFIG_FILE" && RECORD_MIC=true
    fi
fi

# Flags explícitos de CLI tienen prioridad
[ -n "$FLAG_SYS" ] && RECORD_SYS="$FLAG_SYS"
[ -n "$FLAG_MIC" ] && RECORD_MIC="$FLAG_MIC"

# Preparar configuración de audio
setup_audio() {
    AUDIO_ARGS=()
    AUDIO_DESC=""

    cleanup_audio_modules

    if [ "$RECORD_SYS" = "true" ] && [ "$RECORD_MIC" = "true" ]; then
        local sys_sink
        sys_sink=$(pactl get-default-sink 2>/dev/null)
        local mic_source
        mic_source=$(pactl get-default-source 2>/dev/null)
        local sys_monitor="${sys_sink}.monitor"

        pactl load-module module-null-sink sink_name=wf_recorder_combined sink_properties=device.description=wf_recorder_combined >/dev/null 2>&1
        pactl load-module module-loopback sink=wf_recorder_combined source="$sys_monitor" >/dev/null 2>&1
        pactl load-module module-loopback sink=wf_recorder_combined source="$mic_source" >/dev/null 2>&1

        AUDIO_ARGS=(--audio="wf_recorder_combined.monitor")
        AUDIO_DESC=" (Sistema + Micrófono)"
    elif [ "$RECORD_SYS" = "true" ]; then
        local sys_sink
        sys_sink=$(pactl get-default-sink 2>/dev/null)
        local sys_monitor="${sys_sink}.monitor"
        AUDIO_ARGS=(--audio="$sys_monitor")
        AUDIO_DESC=" (Sonido del Sistema)"
    elif [ "$RECORD_MIC" = "true" ]; then
        local mic_source
        mic_source=$(pactl get-default-source 2>/dev/null)
        AUDIO_ARGS=(--audio="$mic_source")
        AUDIO_DESC=" (Micrófono)"
    fi
}

case "$MODE" in
    area)
        GEOM=$(slurp)
        if [ -z "$GEOM" ]; then
            exit 0
        fi
        setup_audio
        notify-send "Grabación de pantalla" "Grabando área seleccionada${AUDIO_DESC}..." -a "Grabación de pantalla"
        (
            wf-recorder "${AUDIO_ARGS[@]}" -g "$GEOM" -f "$FILEPATH"
            cleanup_audio_modules
            notify-send "Grabación de pantalla" "Finalizó la grabación" -a "Grabación de pantalla"
        ) & disown
        ;;
    screen)
        setup_audio
        notify-send "Grabación de pantalla" "Grabando pantalla completa${AUDIO_DESC}..." -a "Grabación de pantalla"
        (
            wf-recorder "${AUDIO_ARGS[@]}" -f "$FILEPATH"
            cleanup_audio_modules
            notify-send "Grabación de pantalla" "Finalizó la grabación" -a "Grabación de pantalla"
        ) & disown
        ;;
    *)
        echo "Uso: $0 {area|screen|stop} [--sound|--no-sound] [--mic|--no-mic]"
        exit 1
        ;;
esac
