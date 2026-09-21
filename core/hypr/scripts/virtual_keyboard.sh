#!/usr/bin/env bash
# ==============================================================================
# virtual_keyboard.sh - Daemon and Toggle Controller for wvkbd (Lunita-Dots)
# ==============================================================================

ENV_FILE="$HOME/.config/hypr/scripts/wvkbd-colors.env"

# Cargar colores dinámicos generados por Matugen si existen
if [ -f "$ENV_FILE" ]; then
    # shellcheck disable=SC1090
    source "$ENV_FILE"
fi

# Paleta estética por defecto (NothingOS / Lunita Dark Glass)
BG_COLOR="${WVKBD_BG:-0b0b0bee}"
FG_COLOR="${WVKBD_FG:-1a1a1aff}"
FG_SP_COLOR="${WVKBD_FG_SP:-262626ff}"
TEXT_COLOR="${WVKBD_TEXT:-ffffffff}"
TEXT_SP_COLOR="${WVKBD_TEXT_SP:-d7c1c2ff}"
PRESS_COLOR="${WVKBD_PRESS:-d71921ff}"
PRESS_SP_COLOR="${WVKBD_PRESS_SP:-d71921ff}"
TEXT_PRESS_COLOR="${WVKBD_TEXT_PRESS:-ffffffff}"
TEXT_PRESS_SP_COLOR="${WVKBD_TEXT_PRESS_SP:-ffffffff}"
ALPHA="${WVKBD_ALPHA:-245}"
FONT="${WVKBD_FONT:-Space Grotesk 14}"
RADIUS="${WVKBD_RADIUS:-12}"
HEIGHT="${WVKBD_HEIGHT:-300}"

# Buscar binario disponible de wvkbd
if command -v wvkbd-deskintl >/dev/null 2>&1; then
    WVKBD_BIN="wvkbd-deskintl"
elif command -v wvkbd-mobintl >/dev/null 2>&1; then
    WVKBD_BIN="wvkbd-mobintl"
elif command -v wvkbd >/dev/null 2>&1; then
    WVKBD_BIN="wvkbd"
else
    echo "Error: wvkbd no está instalado en el sistema." >&2
    exit 1
fi

get_pid() {
    pgrep -x "$WVKBD_BIN" | head -n 1
}

is_visible() {
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl layers 2>/dev/null | grep -q "namespace: wvkbd"
        return $?
    fi
    return 1
}

launch_wvkbd() {
    local extra_args=("$@")
    nohup "$WVKBD_BIN" \
        -H "$HEIGHT" \
        -L "$HEIGHT" \
        -R "$RADIUS" \
        --alpha "$ALPHA" \
        --fn "$FONT" \
        -l full,special \
        --bg "$BG_COLOR" \
        --fg "$FG_COLOR" \
        --fg-sp "$FG_SP_COLOR" \
        --text "$TEXT_COLOR" \
        --text-sp "$TEXT_SP_COLOR" \
        --press "$PRESS_COLOR" \
        --press-sp "$PRESS_SP_COLOR" \
        --text-press "$TEXT_PRESS_COLOR" \
        --text-press-sp "$TEXT_PRESS_SP_COLOR" \
        "${extra_args[@]}" </dev/null >/dev/null 2>&1 &
    disown
}

case "$1" in
    daemon|start)
        PID=$(get_pid)
        if [ -z "$PID" ]; then
            launch_wvkbd --hidden
        fi
        ;;

    show|open)
        PID=$(get_pid)
        if [ -n "$PID" ]; then
            if ! is_visible; then
                kill -s SIGRTMIN "$PID"
            fi
        else
            launch_wvkbd
        fi
        ;;

    hide|close)
        PID=$(get_pid)
        if [ -n "$PID" ]; then
            if is_visible; then
                kill -s SIGRTMIN "$PID"
            fi
        fi
        ;;

    toggle)
        PID=$(get_pid)
        if [ -n "$PID" ]; then
            kill -s SIGRTMIN "$PID"
        else
            launch_wvkbd
        fi
        ;;

    status)
        PID=$(get_pid)
        if [ -z "$PID" ]; then
            echo "stopped"
        elif is_visible; then
            echo "visible"
        else
            echo "hidden"
        fi
        ;;

    is-running)
        PID=$(get_pid)
        [ -n "$PID" ] && exit 0 || exit 1
        ;;

    kill)
        PID=$(get_pid)
        if [ -n "$PID" ]; then
            kill -9 "$PID"
        fi
        ;;

    *)
        echo "Uso: $0 {daemon|start|show|open|hide|close|toggle|status|is-running|kill}"
        exit 1
        ;;
esac
