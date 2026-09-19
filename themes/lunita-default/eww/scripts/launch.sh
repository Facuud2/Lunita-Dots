#!/usr/bin/env bash

# Start eww daemon if not already running
if ! pgrep -x "eww" > /dev/null; then
    eww daemon
    sleep 0.5
fi

# Ensure colors are generated from current wallpaper
if [ ! -f "$HOME/.config/eww/colors.scss" ] || ! grep -q '\$primary' "$HOME/.config/eww/colors.scss" 2>/dev/null; then
    "$HOME/.local/bin/wall-change" >/dev/null 2>&1 || true
fi

# Reload configuration
eww reload
sleep 0.2

ACTIVE=$(eww active-windows 2>/dev/null || true)

# Open music player on both monitors if not already open
if ! echo "$ACTIVE" | grep -q "music_player_0"; then
    eww open music_player_0 2>/dev/null || true
fi

if ! echo "$ACTIVE" | grep -q "music_player_1"; then
    eww open music_player_1 2>/dev/null || true
fi

# Start wallpaper watcher in background if not already running
if ! pgrep -f "watch_wallpaper.sh" > /dev/null; then
    nohup "$HOME/.config/eww/scripts/watch_wallpaper.sh" >/dev/null 2>"$HOME/.config/eww/scripts/watch_wallpaper.sh" >/dev/null 2>&1 &1 &
fi
