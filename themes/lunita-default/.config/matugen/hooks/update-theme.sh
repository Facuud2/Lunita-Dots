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

# Regenerate default cover art with new theme colors
COLORS_FILE="$HOME/.config/eww/colors.scss"
if [ -f "$COLORS_FILE" ]; then
    BG=$(grep '\$surface:' "$COLORS_FILE" | awk '{print $2}' | tr -d ';')
    PRIMARY=$(grep '\$primary:' "$COLORS_FILE" | awk '{print $2}' | tr -d ';')
    OUTLINE=$(grep '\$outline:' "$COLORS_FILE" | awk '{print $2}' | tr -d ';')
    CONTAINER=$(grep '\$surface_container:' "$COLORS_FILE" | awk '{print $2}' | tr -d ';')

    TMP_SVG="$(mktemp --tmpdir="${XDG_RUNTIME_DIR:-/tmp}" lunita_note_XXXXXX.svg)"
    cat << SVG > "$TMP_SVG"
<svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" viewBox="0 0 80 80">
  <rect width="80" height="80" rx="16" fill="${BG:-#1e1e2e}"/>
  <circle cx="40" cy="40" r="28" fill="${CONTAINER:-#181825}" stroke="${OUTLINE:-#313244}" stroke-width="2"/>
  <circle cx="40" cy="40" r="20" fill="none" stroke="${OUTLINE:-#45475a}" stroke-width="1" stroke-dasharray="3,3"/>
  <circle cx="40" cy="40" r="10" fill="${PRIMARY:-#cdd6f4}"/>
  <circle cx="40" cy="40" r="3" fill="${BG:-#181825}"/>
</svg>
SVG
    ffmpeg -y -i "$TMP_SVG" -frames:v 1 -update 1 "$HOME/.config/eww/assets/default_cover.png" >/dev/null 2>&1
    rm -f "$TMP_SVG"
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

# Reload eww
if pgrep -x eww > /dev/null; then
    eww reload
fi

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
