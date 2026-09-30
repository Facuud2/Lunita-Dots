#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import urllib.request
from PIL import Image

CACHE_ART_PATH = "/tmp/lunita_media_art.jpg"

def format_time(seconds):
    try:
        s = int(seconds)
        mins = s // 60
        secs = s % 60
        return f"{mins}:{secs:02d}"
    except Exception:
        return "0:00"

def extract_dominant_color(image_path):
    try:
        if not os.path.exists(image_path):
            return "#0A84FF", [10, 132, 255]
        
        im = Image.open(image_path).convert("RGB")
        im_small = im.resize((32, 32), Image.Resampling.LANCZOS)
        colors = im_small.getcolors(1024)
        if not colors:
            return "#0A84FF", [10, 132, 255]

        # Score colors by saturation & luminance to pick a vibrant dominant accent
        def color_score(count, rgb):
            r, g, b = rgb
            # Calculate saturation
            max_c = max(r, g, b)
            min_c = min(r, g, b)
            delta = max_c - min_c
            sat = delta / max_c if max_c > 0 else 0
            lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
            # Prefer colors with decent saturation and not pitch black or pure white
            if lum < 0.15 or lum > 0.90 or sat < 0.20:
                score = count * 0.1
            else:
                score = count * (1.0 + sat * 2.0)
            return score

        scored = sorted(colors, key=lambda item: color_score(item[0], item[1]), reverse=True)
        chosen = scored[0][1] if scored else (10, 132, 255)
        hex_color = f"#{chosen[0]:02x}{chosen[1]:02x}{chosen[2]:02x}"
        return hex_color, list(chosen)
    except Exception:
        return "#0A84FF", [10, 132, 255]

def get_media_info():
    status = "Stopped"
    title = ""
    artist = ""
    album = ""
    art_url = ""
    pos_sec = 0
    len_sec = 0

    best_player = None
    try:
        players_out = subprocess.check_output(
            ["playerctl", "-l"],
            universal_newlines=True,
            stderr=subprocess.DEVNULL
        ).strip().splitlines()
        
        # Priority order: dedicated music players first
        priority_keywords = ["spotify", "apple-music", "cider", "rhythmbox", "vlc", "mpd"]
        
        candidates = []
        for p in players_out:
            p = p.strip()
            if not p:
                continue
            try:
                p_stat = subprocess.check_output(
                    ["playerctl", "-p", p, "status"],
                    universal_newlines=True,
                    stderr=subprocess.DEVNULL
                ).strip()
            except Exception:
                p_stat = "Stopped"
            
            # Score candidate
            score = 0
            if p_stat.lower() == "playing":
                score += 10
            elif p_stat.lower() == "paused":
                score += 5
            
            for kw in priority_keywords:
                if kw in p.lower():
                    score += 20
                    break
            
            candidates.append((score, p, p_stat))
        
        if candidates:
            candidates.sort(key=lambda c: c[0], reverse=True)
            best_player = candidates[0][1]
            status = candidates[0][2]
    except Exception:
        pass

    if best_player and status != "Stopped":
        try:
            fmt = "{{xesam:title}}\n{{xesam:artist}}\n{{xesam:album}}\n{{mpris:artUrl}}\n{{position}}\n{{mpris:length}}"
            meta_out = subprocess.check_output(
                ["playerctl", "-p", best_player, "metadata", "--format", fmt],
                universal_newlines=True,
                stderr=subprocess.DEVNULL
            ).strip()
            lines = meta_out.splitlines()
            if len(lines) >= 1 and lines[0]:
                title = lines[0]
            if len(lines) >= 2 and lines[1]:
                artist = lines[1]
            if len(lines) >= 3 and lines[2]:
                album = lines[2]
            if len(lines) >= 4 and lines[3]:
                art_url = lines[3]
            if len(lines) >= 5 and lines[4]:
                try:
                    pos_sec = int(int(lines[4]) / 1000000)
                except ValueError:
                    pos_sec = 0
            if len(lines) >= 6 and lines[5]:
                try:
                    len_sec = int(int(lines[5]) / 1000000)
                except ValueError:
                    len_sec = 0
        except Exception:
            pass

    # Resolve local art path
    local_art_path = ""
    if art_url:
        if art_url.startswith("file://"):
            local_art_path = art_url[7:]
        elif art_url.startswith("http://") or art_url.startswith("https://"):
            try:
                urllib.request.urlretrieve(art_url, CACHE_ART_PATH)
                local_art_path = CACHE_ART_PATH
            except Exception:
                pass
        elif os.path.exists(art_url):
            local_art_path = art_url

    # Dominant color
    dom_hex, dom_rgb = extract_dominant_color(local_art_path) if local_art_path else ("#0A84FF", [10, 132, 255])

    return {
        "status": status,
        "is_playing": status.lower() == "playing",
        "title": title if title else "Sin reproducción",
        "artist": artist if artist else "Ningún reproductor activo",
        "album": album,
        "art_url": f"file://{local_art_path}" if local_art_path else "",
        "position": pos_sec,
        "length": len_sec,
        "position_str": format_time(pos_sec),
        "length_str": format_time(len_sec),
        "progress": (pos_sec / len_sec) if len_sec > 0 else 0.0,
        "dominant_color": dom_hex,
        "dominant_rgb": dom_rgb
    }

def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "get"
    
    if cmd == "play-pause":
        try:
            subprocess.run(["playerctl", "play-pause"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass
    elif cmd == "next":
        try:
            subprocess.run(["playerctl", "next"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass
    elif cmd == "previous":
        try:
            subprocess.run(["playerctl", "previous"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass
    elif cmd == "seek" and len(sys.argv) > 2:
        try:
            subprocess.run(["playerctl", "position", sys.argv[2]], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass

    info = get_media_info()
    print(json.dumps(info, ensure_ascii=False))

if __name__ == "__main__":
    main()
