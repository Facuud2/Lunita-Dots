#!/usr/bin/env bash
# ==============================================================================
# 🌙 Lunita-Dots — Eww Widgets Launch Script
# ==============================================================================

wait_for_wayland() {
    local max_attempts=40
    local attempt=0
    local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

    while [ $attempt -lt $max_attempts ]; do
        if [ -n "$WAYLAND_DISPLAY" ] && [ -S "$runtime_dir/$WAYLAND_DISPLAY" ]; then
            return 0
        fi

        local found_sock
        found_sock=$(find "$runtime_dir" -maxdepth 1 -name "wayland-*" -type s 2>/dev/null | head -n 1 || true)
        if [ -n "$found_sock" ]; then
            export WAYLAND_DISPLAY="$(basename "$found_sock")"
            return 0
        fi

        sleep 0.1
        ((attempt++))
    done
}

wait_for_wayland

# Ensure eww daemon is running
if ! pgrep -x eww >/dev/null; then
    eww daemon &
    sleep 0.5
fi

# Detect active monitors from hyprctl
MONITORS=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].id' 2>/dev/null || echo "0")

# Open desktop widgets on each monitor
for mon in $MONITORS; do
    eww open "desktop_widgets_${mon}" 2>/dev/null || eww open desktop_widgets_0 2>/dev/null || true
done
