#!/usr/bin/env bash
# ====================================================================
# EWW LAUNCHER & AUTOSTART SCRIPT
# Starts eww daemon and opens both anime sidebar and music player
# ====================================================================

# 1. Start eww daemon if not already running
if ! eww ping >/dev/null 2>&1; then
    eww daemon &
    # Wait for daemon to respond (up to 5 seconds)
    for i in {1..25}; do
        if eww ping >/dev/null 2>&1; then
            break
        fi
        sleep 0.2
    done
fi

# 2. Ensure dynamic Matugen colors exist
if [ ! -f "$HOME/.config/eww/colors.scss" ] || ! grep -q '\$primary' "$HOME/.config/eww/colors.scss" 2>/dev/null; then
    curr_wall="$(awww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)"
    if [ -n "$curr_wall" ] && [ -f "$curr_wall" ] && command -v matugen &>/dev/null; then
        matugen image "$curr_wall" --source-color-index 0 >/dev/null 2>&1 || true
    fi
fi

# 3. Reload configuration
eww reload >/dev/null 2>&1 || true
sleep 0.3

ACTIVE=$(eww active-windows 2>/dev/null || true)

# 4. Open Anime Sidebar
if ! echo "$ACTIVE" | grep -q "anime_sidebar"; then
    eww open anime_sidebar >/dev/null 2>&1 || true
fi

# 5. Open Music Player on primary monitor
if ! echo "$ACTIVE" | grep -q "music_player_0"; then
    eww open music_player_0 >/dev/null 2>&1 || true
fi

# 6. Open Music Player on secondary monitor if connected
if hyprctl monitors 2>/dev/null | grep -q "Monitor HDMI-A-1"; then
    if ! echo "$ACTIVE" | grep -q "music_player_1"; then
        eww open music_player_1 >/dev/null 2>&1 || true
    fi
fi

# 7. Start wallpaper watcher in background if not already running
if ! pgrep -f "watch_wallpaper.sh" > /dev/null; then
    nohup "$HOME/.config/eww/scripts/watch_wallpaper.sh" >/dev/null 2>&1 &
fi
