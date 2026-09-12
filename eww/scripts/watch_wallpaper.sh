#!/usr/bin/env bash

LAST_WALL=""

# Loop indefinitely to catch any wallpaper change from awww
while true; do
    CURR_WALL=$(/usr/bin/awww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)
    if [ -n "$CURR_WALL" ] && [ -f "$CURR_WALL" ]; then
        if [ "$CURR_WALL" != "$LAST_WALL" ]; then
            if [ -n "$LAST_WALL" ]; then
                matugen image "$CURR_WALL" --source-color-index 0 >/dev/null 2>&1
            fi
            LAST_WALL="$CURR_WALL"
            echo "$CURR_WALL"
        fi
    fi
    sleep 0.8
done
