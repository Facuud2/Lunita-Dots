#!/usr/bin/env bash

CACHE_FILE="/tmp/eww_last_wallpaper"

# Initialize LAST_WALL from cache or active awww query to prevent infinite reload loops
if [ -f "$CACHE_FILE" ]; then
    LAST_WALL=$(cat "$CACHE_FILE")
else
    LAST_WALL=$(/usr/bin/awww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)
    if [ -n "$LAST_WALL" ]; then
        echo "$LAST_WALL" > "$CACHE_FILE"
    fi
fi

if [ -n "$LAST_WALL" ]; then
    echo "$LAST_WALL"
fi

# Loop indefinitely to catch any wallpaper change from awww
while true; do
    CURR_WALL=$(/usr/bin/awww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)
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
    sleep 1
done
