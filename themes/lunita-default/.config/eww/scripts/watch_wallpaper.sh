#!/usr/bin/env bash

# Lockfile para garantizar una sola instancia activa de supervisión
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/lunita_watch_wallpaper.pid"
if [ -f "$LOCK_FILE" ]; then
    OLD_PID=$(cat "$LOCK_FILE" 2>/dev/null || true)
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null && [ "$OLD_PID" != "$$" ]; then
        exit 0
    fi
fi
echo "$$" > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT INT TERM

CACHE_FILE="${XDG_RUNTIME_DIR:-/tmp}/eww_last_wallpaper"

resolve_canon() {
    local p="$1"
    [ -z "$p" ] && echo "" && return
    realpath "$p" 2>/dev/null || echo "$p"
}

# Initialize LAST_WALL from cache or active awww query to prevent infinite reload loops
if [ -f "$CACHE_FILE" ]; then
    LAST_WALL=$(cat "$CACHE_FILE")
else
    RAW_WALL=$(/usr/bin/awww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)
    LAST_WALL=$(resolve_canon "$RAW_WALL")
    if [ -n "$LAST_WALL" ]; then
        echo "$LAST_WALL" > "$CACHE_FILE"
    fi
fi

if [ -n "$LAST_WALL" ]; then
    echo "$LAST_WALL"
fi

# Loop indefinitely to catch any wallpaper change from awww
while true; do
    RAW_WALL=$(/usr/bin/awww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)
    CURR_WALL=$(resolve_canon "$RAW_WALL")

    if [ -n "$CURR_WALL" ] && [ -f "$CURR_WALL" ]; then
        if [ "$CURR_WALL" != "$LAST_WALL" ]; then
            echo "$CURR_WALL" > "$CACHE_FILE"
            LAST_WALL="$CURR_WALL"

            CURRENT_THEME="lunita-default"
            if [ -f "$HOME/.config/lunita/current_theme" ]; then
                CURRENT_THEME=$(tr -d '[:space:]' < "$HOME/.config/lunita/current_theme")
            elif [ -f "$HOME/.lunita-theme" ]; then
                CURRENT_THEME=$(tr -d '[:space:]' < "$HOME/.lunita-theme")
            fi

            if [ "$CURRENT_THEME" = "lunita-default" ]; then
                matugen image "$CURR_WALL" --source-color-index 0 >/dev/null 2>&1
            fi
            echo "$CURR_WALL"
        fi
    fi
    sleep 2
done
