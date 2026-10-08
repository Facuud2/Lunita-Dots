#!/usr/bin/env bash
# ==============================================================================
# 🎵 Lunita Hyprlock & macOS Lockscreen Media Helper
# Extracts live track info, accurate position/duration, and artwork (YouTube, Spotify, etc.)
# ==============================================================================

CACHE_ART="/tmp/hyprlock_art.png"
DEFAULT_ART="${HOME}/.config/hypr/assets/default_cover.png"
FALLBACK_ART="${HOME}/.config/hypr/avatar.jpg"

get_player_status() {
    playerctl status 2>/dev/null || echo "Stopped"
}

truncate_str() {
    local str="$1"
    local max_len="${2:-28}"
    if [ ${#str} -gt "$max_len" ]; then
        echo "${str:0:$((max_len - 3))}..."
    else
        echo "$str"
    fi
}

ensure_default_art() {
    if [ ! -f "$CACHE_ART" ]; then
        if [ -f "$DEFAULT_ART" ]; then
            cp -f "$DEFAULT_ART" "$CACHE_ART"
        elif [ -f "$FALLBACK_ART" ]; then
            cp -f "$FALLBACK_ART" "$CACHE_ART"
        fi
    fi
}

update_art() {
    local status
    status=$(get_player_status)
    if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
        ensure_default_art
        echo "$CACHE_ART"
        return 0
    fi

    # Run Python extractor for comprehensive artwork detection (including YouTube URLs)
    python3 - << 'EOF'
import subprocess, urllib.request, urllib.parse, re, os

cache_art = "/tmp/hyprlock_art.png"
default_art = os.path.expanduser("~/.config/hypr/assets/default_cover.png")

def get_metadata(prop):
    try:
        res = subprocess.check_output(["playerctl", "metadata", "--format", f"{{{{{prop}}}}}"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
        return res
    except Exception:
        return ""

art_url = get_metadata("mpris:artUrl")
xesam_url = get_metadata("xesam:url")

download_url = ""

if art_url:
    if art_url.startswith("file://"):
        local_path = urllib.parse.unquote(art_url[7:])
        if os.path.isfile(local_path):
            try:
                subprocess.run(["convert", local_path, "-resize", "160x160^", "-gravity", "center", "-extent", "160x160", cache_art], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                print(cache_art)
                exit(0)
            except Exception:
                pass
    elif art_url.startswith("http://") or art_url.startswith("https://"):
        download_url = art_url

if not download_url and xesam_url:
    yt_match = re.search(r'(?:v=|\/|youtu\.be\/)([0-9A-Za-z_-]{11})', xesam_url)
    if yt_match:
        vid_id = yt_match.group(1)
        download_url = f"https://img.youtube.com/vi/{vid_id}/hqdefault.jpg"

if download_url:
    tmp_file = "/tmp/hyprlock_dl_raw.jpg"
    try:
        req = urllib.request.Request(download_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=2) as response, open(tmp_file, 'wb') as out_file:
            out_file.write(response.read())
        
        subprocess.run(["convert", tmp_file, "-resize", "160x160^", "-gravity", "center", "-extent", "160x160", cache_art], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        print(cache_art)
        exit(0)
    except Exception:
        pass

if not os.path.exists(cache_art) and os.path.exists(default_art):
    import shutil
    shutil.copy(default_art, cache_art)

print(cache_art)
EOF
}

get_title() {
    local status
    status=$(get_player_status)
    if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
        echo "Apple Music"
        return 0
    fi

    local raw_title
    raw_title=$(playerctl metadata --format '{{title}}' 2>/dev/null || echo "Media")
    [ -z "$raw_title" ] && raw_title="Media"
    truncate_str "$raw_title" 28
}

get_artist() {
    local status
    status=$(get_player_status)
    if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
        echo "No playback active"
        return 0
    fi

    local raw_artist
    raw_artist=$(playerctl metadata --format '{{artist}}' 2>/dev/null || echo "Playing")
    [ -z "$raw_artist" ] && raw_artist="Playing"
    truncate_str "$raw_artist" 28
}

get_progress() {
    local status
    status=$(get_player_status)
    if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
        echo ""
        return 0
    fi

    python3 - << 'EOF'
import subprocess

try:
    pos_str = subprocess.check_output(["playerctl", "position"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
    pos = int(float(pos_str))
except Exception:
    pos = 0

try:
    len_str = subprocess.check_output(["playerctl", "metadata", "--format", "{{mpris:length}}"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
    length = int(len_str) // 1000000 if len_str else 0
except Exception:
    length = 0

if length > 0:
    pos_fmt = f"{pos // 60:02d}:{pos % 60:02d}"
    len_fmt = f"{length // 60:02d}:{length % 60:02d}"
    print(f"{pos_fmt} / {len_fmt}")
elif pos > 0:
    pos_fmt = f"{pos // 60:02d}:{pos % 60:02d}"
    print(pos_fmt)
else:
    print("")
EOF
}

get_controls() {
    local status
    status=$(get_player_status)

    local play_icon="󰐊"
    if [ "$status" == "Playing" ]; then
        play_icon="󰏤"
    fi

    local progress
    progress=$(get_progress)

    if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
        echo "󰒮   $play_icon   󰒭"
        return 0
    fi

    if [ -n "$progress" ]; then
        echo "󰒮   $play_icon   󰒭    $progress"
    else
        echo "󰒮   $play_icon   󰒭"
    fi
}

get_all_json() {
    python3 - << 'EOF'
import subprocess, json

def get_prop(p):
    try:
        return subprocess.check_output(["playerctl", "metadata", "--format", f"{{{{{p}}}}}"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
    except Exception:
        return ""

try:
    status = subprocess.check_output(["playerctl", "status"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
except Exception:
    status = "Stopped"

active = (status in ["Playing", "Paused"])
title = get_prop("title") or "Apple Music"
artist = get_prop("artist") or ("Playing" if active else "No playback active")

try:
    pos = int(float(subprocess.check_output(["playerctl", "position"], stderr=subprocess.DEVNULL).decode("utf-8").strip()))
except Exception:
    pos = 0

try:
    len_str = get_prop("mpris:length")
    length = int(len_str) // 1000000 if len_str else 0
except Exception:
    length = 0

if active and length > 0:
    time_str = f"{pos // 60:02d}:{pos % 60:02d} / {length // 60:02d}:{length % 60:02d}"
elif active and pos > 0:
    time_str = f"{pos // 60:02d}:{pos % 60:02d}"
else:
    time_str = ""

data = {
    "active": active,
    "status": status,
    "isPlaying": (status == "Playing"),
    "title": title[:28] + ("..." if len(title) > 28 else ""),
    "artist": artist[:28] + ("..." if len(artist) > 28 else ""),
    "timeProgress": time_str
}
print(json.dumps(data))
EOF
}

case "$1" in
    art|get_art)
        update_art
        ;;
    title)
        get_title
        ;;
    artist)
        get_artist
        ;;
    progress)
        get_progress
        ;;
    controls)
        get_controls
        ;;
    json)
        get_all_json
        ;;
    *)
        get_title
        ;;
esac
