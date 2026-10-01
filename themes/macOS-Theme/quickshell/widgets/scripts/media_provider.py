#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
import time
import urllib.parse
import urllib.request
from PIL import Image

CACHE_ART_PATH = "/tmp/lunita_media_art.jpg"
CACHE_TITLE_FILE = "/tmp/lunita_media_title.txt"

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
        im_small = im.resize((48, 48), Image.Resampling.LANCZOS)
        colors = im_small.getcolors(2304)
        if not colors:
            return "#0A84FF", [10, 132, 255]

        def color_score(count, rgb):
            r, g, b = rgb
            max_c = max(r, g, b)
            min_c = min(r, g, b)
            delta = max_c - min_c
            sat = delta / max_c if max_c > 0 else 0
            lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
            if lum < 0.20 or lum > 0.88 or sat < 0.25:
                return count * 0.001
            return count * (1.0 + sat * 3.0)

        scored = sorted(colors, key=lambda item: color_score(item[0], item[1]), reverse=True)
        chosen = scored[0][1] if scored else (10, 132, 255)
        hex_color = f"#{chosen[0]:02x}{chosen[1]:02x}{chosen[2]:02x}"
        return hex_color, list(chosen)
    except Exception:
        return "#0A84FF", [10, 132, 255]

def get_best_player():
    try:
        players_out = subprocess.check_output(
            ["playerctl", "-l"],
            universal_newlines=True,
            stderr=subprocess.DEVNULL
        ).strip().splitlines()
        
        priority_keywords = ["spotify", "apple-music", "cider", "rhythmbox", "vlc", "mpd", "firefox", "zen", "chrome"]
        
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
            
            score = 0
            if p_stat.lower() == "playing":
                score += 20
            elif p_stat.lower() == "paused":
                score += 5
            
            for idx, kw in enumerate(priority_keywords):
                if kw in p.lower():
                    score += (len(priority_keywords) - idx) * 2
                    break
            
            candidates.append((score, p, p_stat))
        
        if candidates:
            candidates.sort(key=lambda c: c[0], reverse=True)
            return candidates[0][1], candidates[0][2]
    except Exception:
        pass
    return None, "Stopped"

def get_browser_active_title():
    """Extract actual video/song title and source from active Hyprland browser windows"""
    try:
        out = subprocess.check_output(['hyprctl', 'clients', '-j'], text=True, stderr=subprocess.DEVNULL)
        clients = json.loads(out)
        for c in clients:
            cls = c.get('class', '').lower()
            title = c.get('title', '')
            if any(b in cls for b in ['zen', 'firefox', 'chrome', 'chromium', 'brave']) and title:
                # Clean title: strip browser and private browsing markers
                clean = re.sub(r'\s*—\s*(Zen Browser|Mozilla Firefox|Google Chrome|Brave).*$', '', title, flags=re.I)
                clean = re.sub(r'\s*[-—]\s*(Navegación privada|Private Browsing).*$', '', clean, flags=re.I).strip()
                if not clean or clean.lower() in ('nueva pestaña', 'new tab', 'zen browser', 'mozilla firefox'):
                    continue
                
                artist = "Navegador Web"
                vid_title = clean
                if "- YouTube" in clean:
                    parts = clean.split("- YouTube")
                    vid_title = parts[0].strip()
                    artist = "YouTube"
                elif "SoundCloud" in clean:
                    parts = clean.split("-")
                    vid_title = parts[0].strip()
                    artist = "SoundCloud"
                elif "Twitch" in clean:
                    artist = "Twitch"
                elif "Spotify" in clean:
                    artist = "Spotify Web"
                
                return {"title": vid_title, "artist": artist, "is_youtube": (artist == "YouTube")}
    except Exception:
        pass
    return None

def fetch_youtube_thumb(query_title):
    try:
        # Check cache
        if os.path.exists(CACHE_TITLE_FILE) and os.path.exists(CACHE_ART_PATH):
            try:
                with open(CACHE_TITLE_FILE, "r", encoding="utf-8") as f:
                    cached_t = f.read().strip()
                if cached_t == query_title.strip() and os.path.getsize(CACHE_ART_PATH) > 1000:
                    return CACHE_ART_PATH
            except Exception:
                pass
        
        q = urllib.parse.quote(query_title)
        url = f"https://www.youtube.com/results?search_query={q}"
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (X11; Linux x86_64)"})
        with urllib.request.urlopen(req, timeout=3) as resp:
            html = resp.read().decode("utf-8", errors="ignore")
            m = re.search(r'\"videoId\":\"([a-zA-Z0-9_-]{11})\"', html)
            if m:
                vid_id = m.group(1)
                thumb_url = f"https://i.ytimg.com/vi/{vid_id}/hqdefault.jpg"
                urllib.request.urlretrieve(thumb_url, CACHE_ART_PATH)
                with open(CACHE_TITLE_FILE, "w", encoding="utf-8") as f:
                    f.write(query_title.strip())
                return CACHE_ART_PATH
    except Exception:
        pass
    return ""

def get_media_info():
    best_player, status = get_best_player()
    title = ""
    artist = ""
    album = ""
    art_url = ""
    pos_sec = 0
    len_sec = 0

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
                title = lines[0].strip()
            if len(lines) >= 2 and lines[1]:
                artist = lines[1].strip()
            if len(lines) >= 3 and lines[2]:
                album = lines[2].strip()
            if len(lines) >= 4 and lines[3]:
                art_url = lines[3].strip()
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

    # Detect private browsing / generic browser placeholder
    is_generic = (not title) or ("reproduciendo contenido multimedia" in title.lower()) or (not artist and any(b in (best_player or "").lower() for b in ["firefox", "zen", "chrome", "chromium"]))
    
    local_art_path = ""
    if is_generic:
        browser_info = get_browser_active_title()
        if browser_info:
            title = browser_info["title"]
            artist = browser_info["artist"]
            if browser_info["is_youtube"] and not art_url:
                local_art_path = fetch_youtube_thumb(title)

    # Resolve local art path from mpris if not already found
    if not local_art_path and art_url:
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

    # Fallback dominant color
    dom_hex, dom_rgb = extract_dominant_color(local_art_path) if local_art_path else ("#0A84FF", [10, 132, 255])

    return {
        "player": best_player or "",
        "status": status,
        "is_playing": status.lower() == "playing",
        "title": title if title else "Sin reproducción",
        "artist": artist if artist else ("En pausa" if status.lower() == "paused" else "Ningún reproductor activo"),
        "album": album,
        "art_url": f"file://{local_art_path}" if (local_art_path and os.path.exists(local_art_path)) else "",
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
    best_player, _ = get_best_player()
    
    player_args = ["-p", best_player] if best_player else []

    if cmd == "play-pause":
        try:
            subprocess.run(["playerctl"] + player_args + ["play-pause"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            time.sleep(0.12)
        except Exception:
            pass
    elif cmd == "next":
        try:
            subprocess.run(["playerctl"] + player_args + ["next"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            time.sleep(0.12)
        except Exception:
            pass
    elif cmd == "previous":
        try:
            subprocess.run(["playerctl"] + player_args + ["previous"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            time.sleep(0.12)
        except Exception:
            pass
    elif cmd == "seek" and len(sys.argv) > 2:
        try:
            subprocess.run(["playerctl"] + player_args + ["position", sys.argv[2]], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass

    info = get_media_info()
    print(json.dumps(info, ensure_ascii=False))

if __name__ == "__main__":
    main()
