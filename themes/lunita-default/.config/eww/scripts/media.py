#!/usr/bin/env python3
import os
import sys
import json
import time
import urllib.parse
import subprocess

CACHE_DIR = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "eww_music")
os.makedirs(CACHE_DIR, exist_ok=True)

DEFAULT_COVER = os.path.expanduser("~/.config/eww/assets/default_cover.png")
COVER_A = os.path.join(CACHE_DIR, "cover_a.png")
COVER_B = os.path.join(CACHE_DIR, "cover_b.png")

current_cover_toggle = False
last_art_source = None
current_cover_path = DEFAULT_COVER

def process_cover_with_ffmpeg(art_url, track_url):
    global current_cover_toggle, last_art_source, current_cover_path

    source = None
    if art_url:
        if art_url.startswith("file://"):
            source = urllib.parse.unquote(art_url[7:])
        else:
            source = art_url
    elif track_url and track_url.startswith("file://"):
        source = urllib.parse.unquote(track_url[7:])

    if not source:
        current_cover_path = DEFAULT_COVER
        last_art_source = None
        return current_cover_path

    if source == last_art_source and os.path.exists(current_cover_path):
        return current_cover_path

    target_cover = COVER_B if current_cover_toggle else COVER_A
    current_cover_toggle = not current_cover_toggle

    try:
        cmd = [
            "ffmpeg", "-y",
            "-i", source,
            "-vf", "scale=120:120:force_original_aspect_ratio=increase,crop=120:120",
            "-frames:v", "1",
            "-update", "1",
            target_cover
        ]
        result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=4)
        if result.returncode == 0 and os.path.exists(target_cover):
            current_cover_path = target_cover
            last_art_source = source
            return current_cover_path
    except Exception:
        pass

    current_cover_path = DEFAULT_COVER
    return current_cover_path

def clean_player_name(raw_player):
    if not raw_player:
        return ""
    name = raw_player.split(".")[0].capitalize()
    if name.lower() == "firefox":
        try:
            check_zen = subprocess.run(["pgrep", "-f", "zen"], stdout=subprocess.PIPE)
            if check_zen.returncode == 0:
                return "Zen"
        except Exception:
            pass
        return "Firefox"
    elif name.lower() == "chromium":
        return "Chromium"
    elif name.lower() == "spotify":
        return "Spotify"
    return name

def emit_json(status, player, title, artist, cover, has_media):
    data = {
        "status": status,
        "player": player,
        "title": title if title else "No Music Playing",
        "artist": artist if artist else "",
        "cover": cover,
        "has_media": has_media
    }
    sys.stdout.write(json.dumps(data) + "\n")
    sys.stdout.flush()

def emit_idle():
    emit_json(
        status="Stopped",
        player="",
        title="No Music Playing",
        artist="",
        cover=DEFAULT_COVER,
        has_media=False
    )

def handle_line(line):
    try:
        line = line.strip()
        if not line:
            return
        parts = line.split("||")
        status = parts[0] if len(parts) > 0 else "Stopped"
        raw_player = parts[1] if len(parts) > 1 else ""
        title = parts[2] if len(parts) > 2 else ""
        artist = parts[3] if len(parts) > 3 else ""
        art_url = parts[4] if len(parts) > 4 else ""
        track_url = parts[5] if len(parts) > 5 else ""

        has_media = bool(status in ("Playing", "Paused") and (title or artist))
        player = clean_player_name(raw_player)
        cover = process_cover_with_ffmpeg(art_url, track_url)

        emit_json(
            status=status,
            player=player,
            title=title if title else "No Music Playing",
            artist=artist,
            cover=cover,
            has_media=has_media
        )
    except Exception:
        emit_idle()

def main():
    fmt = "{{status}}||{{playerName}}||{{title}}||{{artist}}||{{mpris:artUrl}}||{{xesam:url}}"

    while True:
        try:
            # Check current metadata first
            curr = subprocess.run(
                ["playerctl", "metadata", "--format", fmt],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True
            )
            handled = False
            if curr.returncode == 0 and curr.stdout.strip():
                for l in curr.stdout.strip().splitlines():
                    if l.strip():
                        handle_line(l.strip())
                        handled = True
                        break
            if not handled:
                emit_idle()

            # Follow for subsequent events
            proc = subprocess.Popen(
                ["playerctl", "metadata", "--follow", "--format", fmt],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True
            )

            for line in proc.stdout:
                handle_line(line)

            proc.wait()
        except Exception:
            emit_idle()
            time.sleep(1.5)

if __name__ == "__main__":
    main()
