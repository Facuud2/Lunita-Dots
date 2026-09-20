#!/bin/bash

umask 077

runtime_root="${XDG_RUNTIME_DIR:-/tmp}"
lock_mutex="${runtime_root}/hypr_smart_lock.lock"

# 1. Prevent multiple concurrent lock attempts / race conditions
exec 9>"$lock_mutex"
if ! flock -n 9; then
    exit 0
fi

# 2. Check if lockscreen is already running
if pgrep -f "LockShell.qml" >/dev/null 2>&1 || pidof hyprlock >/dev/null 2>&1; then
    exit 0
fi

# 3. Check if session is already locked in Hyprland
if [[ "$(hyprctl locked 2>/dev/null)" == "true" ]]; then
    exit 0
fi

# Auto-sync wallpaper and matugen colors if wallpaper changed
if command -v awww >/dev/null 2>&1; then
    curr_wall=$(awww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)
    if [ -n "$curr_wall" ] && [ -f "$curr_wall" ]; then
        if [ ! -f "$HOME/.config/hypr/current_wallpaper.png" ] || [ "$curr_wall" -nt "$HOME/.config/hypr/current_wallpaper.png" ]; then
            cp "$curr_wall" "$HOME/.config/hypr/current_wallpaper.png"
            if command -v matugen >/dev/null 2>&1; then
                matugen image "$curr_wall" --source-color-index 0 >/dev/null 2>&1
            fi
        fi
    fi
fi

# Ensure wallpaper cache for Serpantine lock is synchronized
mkdir -p "$HOME/.cache/serpantinum/wallpaper"
if [ -f "$HOME/.config/hypr/current_wallpaper.png" ]; then
    cp -f "$HOME/.config/hypr/current_wallpaper.png" "$HOME/.cache/serpantinum/wallpaper/current_wallpaper.png" 2>/dev/null || true
    if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        for mon in $(hyprctl monitors -j 2>/dev/null | jq -r '.[].name // empty'); do
            [ -n "$mon" ] && cp -f "$HOME/.config/hypr/current_wallpaper.png" "$HOME/.cache/serpantinum/wallpaper/current_wallpaper_${mon}.png" 2>/dev/null || true
        done
    fi
fi

# Ensure notifications cache exists
if [ ! -s /tmp/notifications_cache.json ]; then
    cat << 'NOTIFS' > /tmp/notifications_cache.json
[
  {
    "id": 1,
    "appName": "Screen recorder",
    "appIcon": "video-display",
    "summary": "Screen recorder",
    "body": "Recording started: Press y...",
    "actions": [],
    "urgency": "normal",
    "timestamp": 1789768000000,
    "timeFormatted": "now"
  },
  {
    "id": 2,
    "appName": "Telegram",
    "appIcon": "telegram",
    "summary": "Любимая жена 💖",
    "body": "Video message",
    "actions": [],
    "urgency": "normal",
    "timestamp": 1789767900000,
    "timeFormatted": "Just now"
  }
]
NOTIFS
fi

# Run Quickshell Lockscreen
serpantinum_dir="$HOME/.local/share/serpantinum/src"
main_qml="$serpantinum_dir/quickshell/LockShell.qml"

if command -v quickshell >/dev/null 2>&1 && [ -f "$main_qml" ]; then
    export SERPANTINUM_DIR="$serpantinum_dir"
    source "$SERPANTINUM_DIR/scripts/caching.sh"
    export MAIN_QML="$main_qml"
    qs_ensure_cache "lock"

    quickshell -p "$MAIN_QML"
    status=$?
else
    # Fallback to stock hyprlock if quickshell is unavailable
    /usr/bin/hyprlock
    status=$?
fi

exit "$status"
