#!/usr/bin/env bash
# ==============================================================================
# 🔒 Lunita Smart Lock Controller
# ==============================================================================

umask 077

runtime_root="${XDG_RUNTIME_DIR:-/tmp}"
lock_mutex="${runtime_root}/hypr_smart_lock.lock"

# 1. Prevent multiple concurrent lock attempts / race conditions
exec 9>"$lock_mutex"
if ! flock -n 9; then
    exit 0
fi

# 2. Check if lockscreen is already running
if pgrep -f "quickshell.*lockscreen" >/dev/null 2>&1 || pidof hyprlock >/dev/null 2>&1; then
    exit 0
fi

# 3. Check if session is already locked in Hyprland
if [[ "$(hyprctl locked 2>/dev/null)" == "true" ]]; then
    exit 0
fi

# 4. Auto-sync wallpaper if changed
if command -v awww >/dev/null 2>&1; then
    curr_wall=$(awww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)
    if [ -n "$curr_wall" ] && [ -f "$curr_wall" ]; then
        if [ ! -f "$HOME/.config/hypr/current_wallpaper.png" ] || [ "$curr_wall" -nt "$HOME/.config/hypr/current_wallpaper.png" ]; then
            cp "$curr_wall" "$HOME/.config/hypr/current_wallpaper.png"
        fi
    fi
fi

# Pre-cache media art for instantaneous lockscreen rendering
if [ -x "$HOME/.config/hypr/scripts/lock_media.sh" ]; then
    "$HOME/.config/hypr/scripts/lock_media.sh" art >/dev/null 2>&1 &
fi

mode="${1:-auto}"
qs_lock_dir="$HOME/.config/quickshell/lockscreen"

# 1. Prioritize theme's native Quickshell Lockscreen
if [ "$mode" != "hyprlock" ] && command -v quickshell >/dev/null 2>&1 && [ -f "$qs_lock_dir/shell.qml" ]; then
    quickshell -p "$qs_lock_dir"
    status=$?
    if [ $status -eq 0 ]; then
        exit 0
    fi
fi

# 2. Fallback to Hyprlock
/usr/bin/hyprlock
status=$?

exit "$status"
