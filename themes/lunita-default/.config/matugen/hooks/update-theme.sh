#!/usr/bin/env bash

# Verificar que el tema activo sea lunita-default
CURRENT_THEME="lunita-default"
if [ -f "$HOME/.config/lunita/current_theme" ]; then
    CURRENT_THEME=$(tr -d '[:space:]' < "$HOME/.config/lunita/current_theme")
elif [ -f "$HOME/.lunita-theme" ]; then
    CURRENT_THEME=$(tr -d '[:space:]' < "$HOME/.lunita-theme")
fi

if [ "$CURRENT_THEME" != "lunita-default" ]; then
    exit 0
fi

# Lockfile para evitar ejecuciones simultáneas o en bucle
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/lunita_matugen_hook.lock"
if [ -f "$LOCK_FILE" ]; then
    LOCK_AGE=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0) ))
    if [ "$LOCK_AGE" -lt 2 ]; then
        exit 0
    fi
fi
touch "$LOCK_FILE"

# Reload Hyprland para aplicar nueva paleta de bordes (colors.lua)
if pgrep -x Hyprland > /dev/null; then
    hyprctl reload
fi

# Reload Kitty
if pgrep -x kitty > /dev/null; then
    kill -SIGUSR1 $(pgrep -x kitty) 2>/dev/null || true
fi

# Touch Vesktop Quick CSS to trigger hot reload in Vencord if running
if pgrep -i vesktop > /dev/null; then
    touch "$HOME/.config/vesktop/settings/quickCss.css" 2>/dev/null || true
fi

# Notify KDE applications (like Dolphin) about palette update
if command -v dbus-send > /dev/null; then
    dbus-send --type=signal /KGlobalSettings org.kde.KGlobalSettings.notifyChange int32:0 int32:0 2>/dev/null || true
fi

# Update hyprlock wallpaper copy to match active wallpaper if distinct
CURR_WALL=$(awww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)
TARGET_HYPR_WALL="$HOME/.config/hypr/current_wallpaper.png"
if [ -n "$CURR_WALL" ] && [ -f "$CURR_WALL" ]; then
    REAL_CURR=$(realpath "$CURR_WALL" 2>/dev/null || echo "$CURR_WALL")
    REAL_TARGET=$(realpath "$TARGET_HYPR_WALL" 2>/dev/null || echo "$TARGET_HYPR_WALL")
    if [ "$REAL_CURR" != "$REAL_TARGET" ]; then
        cp -f "$CURR_WALL" "$TARGET_HYPR_WALL" 2>/dev/null || true
    fi
fi
