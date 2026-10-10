#!/usr/bin/env bash

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

# Reload eww
if pgrep -x eww > /dev/null; then
    eww reload
fi

# Reload Hyprland
if pgrep -x Hyprland > /dev/null; then
    hyprctl reload
fi

# Reload Kitty
if pgrep -x kitty > /dev/null; then
    kill -SIGUSR1 $(pgrep -x kitty) 2>/dev/null || true
fi

# Reload Quickshell (Dynamic Island, Launcher, Notifications, OSD)
if command -v lunita-quickshell >/dev/null 2>&1; then
    lunita-quickshell restart >/dev/null 2>&1 || true
fi

# Touch Vesktop Quick CSS to trigger hot reload in Vencord if running
if pgrep -i vesktop > /dev/null; then
    touch "$HOME/.config/vesktop/settings/quickCss.css" 2>/dev/null || true
fi

# Notify KDE applications (like Dolphin) about palette update
if command -v dbus-send > /dev/null; then
    dbus-send --type=signal /KGlobalSettings org.kde.KGlobalSettings.notifyChange int32:0 int32:0 2>/dev/null || true
fi

# Update hyprlock wallpaper copy to match active wallpaper
CURR_WALL=$(awww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)
if [ -n "$CURR_WALL" ] && [ -f "$CURR_WALL" ]; then
    cp "$CURR_WALL" "$HOME/.config/hypr/current_wallpaper.png"
fi

# Sync palette with Lunita design tokens orchestrator
if command -v lunita-palette-sync >/dev/null 2>&1; then
    lunita-palette-sync sync 2>/dev/null || true
fi
