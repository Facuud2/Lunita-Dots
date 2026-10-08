#!/usr/bin/env bash
# ==============================================================================
# virtual_keyboard.sh - Daemon and Toggle Controller for wvkbd (Lunita-Dots)
# ==============================================================================

ENV_FILE="$HOME/.config/hypr/scripts/wvkbd-colors.env"
[ -f "$ENV_FILE" ] && source "$ENV_FILE"

# Paleta estética moderna macOS (Apple Cupertino Glass)
BG_COLOR="${WVKBD_BG:-1e1e1e}"
FG_COLOR="${WVKBD_FG:-2a2b30}"
FG_SP_COLOR="${WVKBD_FG_SP:-1d1e22}"
TEXT_COLOR="${WVKBD_TEXT:-f5f5f7}"
TEXT_SP_COLOR="${WVKBD_TEXT_SP:-a1a1a6}"
PRESS_COLOR="${WVKBD_PRESS:-007aff}"
PRESS_SP_COLOR="${WVKBD_PRESS_SP:-007aff}"
TEXT_PRESS_COLOR="${WVKBD_TEXT_PRESS:-ffffff}"
TEXT_PRESS_SP_COLOR="${WVKBD_TEXT_PRESS_SP:-ffffff}"

ALPHA="${WVKBD_ALPHA:-240}"
BG_ALPHA="${WVKBD_BG_ALPHA:-165}"
FONT="${WVKBD_FONT:-SF Pro Display 14}"
KEY_RADIUS="${WVKBD_RADIUS:-10}"
CORNER_RADIUS="${WVKBD_CORNER_RADIUS:-22}"
HEIGHT="${WVKBD_HEIGHT:-310}"

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
        -R "$KEY_RADIUS" \
        --corner-radius "$CORNER_RADIUS" \
        --bg-alpha "$BG_ALPHA" \
        --alpha "$ALPHA" \
        --fn "$FONT" \
        -l full,special \
        --no-popup \
        --bg "$BG_COLOR" \
        --fg "$FG_COLOR" \
        --fg-sp "$FG_SP_COLOR" \
        --text "$TEXT_COLOR" \
        --text-sp "$TEXT_SP_COLOR" \
        --press "$PRESS_COLOR" \
        --press-sp "$PRESS_SP_COLOR" \
        --text-press "$TEXT_PRESS_COLOR" \
        --text-press-sp "$TEXT_PRESS_SP_COLOR" \
        --wayland-layer overlay \
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
