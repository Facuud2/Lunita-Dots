#!/usr/bin/env bash
#
# hyprquickpaper wallpaper backend dispatcher
# ---------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$DIR/config.json"
source "$DIR/common.sh"

WALLPAPER="$1"
WALLPAPER="${WALLPAPER#file://}"
if [ -z "$WALLPAPER" ]; then
    exit 0
fi

TOOL=$(jq -r '.wallpaper_tool // "awww"' "$CONFIG")
VIDEO_EXT_PATTERN=$(get_video_extensions_pattern "$CONFIG")

# ALWAYS kill any running video wallpaper first, whether we're about to
# set an image or a different video — otherwise the old mpvpaper process
# keeps rendering underneath/instead of the new wallpaper.
pkill mpvpaper 2>/dev/null

CACHE_PATH=$(jq -r '.cache_path // "~/.cache/quickshell/thumbs/"' "$CONFIG" | sed "s|^~|$HOME|")
CACHE_PATH="${CACHE_PATH%/}/"
FILENAME_NOEXT="$(basename "$WALLPAPER")"
FILENAME_NOEXT="${FILENAME_NOEXT%.*}"
THUMB="${CACHE_PATH}${FILENAME_NOEXT}.jpg"

if is_video "$WALLPAPER" "$VIDEO_EXT_PATTERN"; then
    echo "Detected video file: $WALLPAPER"

    if command -v mpvpaper &>/dev/null; then
        MONITOR=$(get_monitor_output)
        echo "Using monitor: $MONITOR"

        # -f forks mpvpaper into the background itself
        # -p auto-pauses when windows cover the wallpaper
        mpvpaper -f -p -o "no-audio loop" "$MONITOR" "$WALLPAPER"

        sleep 0.5
        if pgrep -f "mpvpaper.*$WALLPAPER" >/dev/null; then
            echo "✅ Video wallpaper started successfully on $MONITOR"
        else
            echo "⚠️  mpvpaper may not have started correctly"
        fi
    else
        echo "Error: mpvpaper not found. Please install it for video wallpapers."
        exit 1
    fi
else
    # Garantizar que el demonio de fondo esté activo antes de cambiar wallpaper
    if [ "$TOOL" = "awww" ] || [ "$TOOL" = "swww" ]; then
        if command -v awww-daemon &>/dev/null && ! pgrep -x awww-daemon >/dev/null; then
            if command -v hyprctl &>/dev/null && pgrep -x Hyprland >/dev/null; then
                hyprctl dispatch exec awww-daemon >/dev/null 2>&1 || true
            fi
            if ! pgrep -x awww-daemon >/dev/null; then
                nohup awww-daemon >/dev/null 2>&1 &
            fi
            for _ in {1..30}; do
                if awww query >/dev/null 2>&1; then break; fi
                sleep 0.05
            done
        elif command -v swww-daemon &>/dev/null && ! pgrep -x swww-daemon >/dev/null; then
            nohup swww-daemon >/dev/null 2>&1 &
            for _ in {1..30}; do
                if swww query >/dev/null 2>&1; then break; fi
                sleep 0.05
            done
        fi
    fi

    echo "Using $TOOL for image wallpaper: $WALLPAPER"

    case "$TOOL" in
        awww|swww)
            # Fluid transition with awww
            awww img "$WALLPAPER" --transition-type grow --transition-duration 1.2 --transition-fps 60
            ;;
        hyprpaper)
            hyprctl hyprpaper preload "$WALLPAPER" 2>/dev/null
            hyprctl hyprpaper wallpaper ",$WALLPAPER"
            ;;
        waypaper)
            waypaper --wallpaper "$WALLPAPER"
            ;;
        swaybg)
            pkill swaybg 2>/dev/null
            swaybg -i "$WALLPAPER" -m fill &
            ;;
        feh)
            feh --bg-fill "$WALLPAPER"
            ;;
        *)
            echo "hyprquickpaper: unknown wallpaper_tool '$TOOL' in config.json, defaulting to awww" >&2
            awww img "$WALLPAPER" --transition-type grow --transition-duration 1.2 --transition-fps 60
            ;;
    esac
fi

# Track the active wallpaper ourselves so the picker can highlight it
mkdir -p "$HOME/.cache/hyprquickpaper"
echo "$WALLPAPER" > "$HOME/.cache/hyprquickpaper/current_wallpaper"

# --- Keep a copy of the current wallpaper at a fixed path (e.g. for hyprlock) ---
STABLE_COPY_PATH=$(jq -r '.stable_copy_path // ""' "$CONFIG")
if [ -n "$STABLE_COPY_PATH" ]; then
    EXPANDED_COPY_PATH="${STABLE_COPY_PATH/#\~/$HOME}"
    mkdir -p "$(dirname "$EXPANDED_COPY_PATH")"

    if is_video "$WALLPAPER" "$VIDEO_EXT_PATTERN"; then
        if [ -f "$THUMB" ]; then
            cp "$THUMB" "$EXPANDED_COPY_PATH"
        else
            echo "hyprquickpaper: no cached thumbnail found for '$WALLPAPER', skipping stable_copy_path update" >&2
        fi
    else
        cp "$WALLPAPER" "$EXPANDED_COPY_PATH"
    fi
fi

# --- Matugen dynamic theming integration (solo lunita-default) ---
CURRENT_THEME="lunita-default"
if [ -f "$HOME/.config/lunita/current_theme" ]; then
    CURRENT_THEME=$(tr -d '[:space:]' < "$HOME/.config/lunita/current_theme")
elif [ -f "$HOME/.lunita-theme" ]; then
    CURRENT_THEME=$(tr -d '[:space:]' < "$HOME/.lunita-theme")
fi
CURRENT_THEME="${CURRENT_THEME,,}"

if [ "$CURRENT_THEME" = "lunita-default" ] && command -v matugen &>/dev/null; then
    if is_video "$WALLPAPER" "$VIDEO_EXT_PATTERN"; then
        if [ -f "$THUMB" ]; then
            matugen image "$THUMB" --source-color-index 0 >/dev/null 2>&1 &
        fi
    else
        matugen image "$WALLPAPER" --source-color-index 0 >/dev/null 2>&1 &
    fi
fi
