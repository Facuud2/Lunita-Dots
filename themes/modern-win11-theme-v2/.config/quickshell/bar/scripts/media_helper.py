#!/usr/bin/env python3
import sys
import os
import subprocess
import json
import re
import time
import urllib.parse
import urllib.request
import threading

CACHE_DURATIONS = {}
FETCHING = set()
RESOLVED_ARTS = {}
RESOLVING_ARTS = set()

SEEK_FILE = "/tmp/lunita_media_seek.txt"
CACHE_ART_PATH = "/tmp/lunita_bar_art.jpg"
CACHE_ART_KEY = "/tmp/lunita_bar_art_key.txt"

def fetch_yt_duration(vid_id):
    if vid_id in CACHE_DURATIONS or vid_id in FETCHING:
        return
    FETCHING.add(vid_id)
    try:
        url = f"https://www.youtube.com/watch?v={vid_id}"
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (X11; Linux x86_64)"})
        with urllib.request.urlopen(req, timeout=2.5) as resp:
            html = resp.read().decode("utf-8", errors="ignore")
            m = re.search(r'\"approxDurationMs\":\"(\d+)\"', html)
            if m:
                CACHE_DURATIONS[vid_id] = int(m.group(1)) // 1000
            else:
                m2 = re.search(r'\"lengthSeconds\":\"(\d+)\"', html)
                if m2:
                    CACHE_DURATIONS[vid_id] = int(m2.group(1))
    except Exception:
        pass
    finally:
        FETCHING.discard(vid_id)

def resolve_cover_art_worker(art_url, title, artist, url, vid_id, track_key):
    try:
        # 1. Direct local file URL
        if art_url and art_url.startswith("file://"):
            RESOLVED_ARTS[track_key] = art_url
            return

        # 2. Remote URL from MPRIS (Spotify, etc.)
        if art_url and (art_url.startswith("http://") or art_url.startswith("https://")):
            try:
                urllib.request.urlretrieve(art_url, CACHE_ART_PATH)
                with open(CACHE_ART_KEY, "w", encoding="utf-8") as f:
                    f.write(track_key)
                RESOLVED_ARTS[track_key] = f"file://{CACHE_ART_PATH}"
                return
            except Exception:
                RESOLVED_ARTS[track_key] = art_url
                return

        # 3. Direct YouTube video ID thumbnail
        if vid_id:
            try:
                thumb = f"https://i.ytimg.com/vi/{vid_id}/hqdefault.jpg"
                urllib.request.urlretrieve(thumb, CACHE_ART_PATH)
                with open(CACHE_ART_KEY, "w", encoding="utf-8") as f:
                    f.write(track_key)
                RESOLVED_ARTS[track_key] = f"file://{CACHE_ART_PATH}"
                return
            except Exception:
                RESOLVED_ARTS[track_key] = f"https://i.ytimg.com/vi/{vid_id}/hqdefault.jpg"
                return

        # 4. Search query on iTunes or YouTube if title is present
        if title and title.strip() and "sin reproducción" not in title.lower():
            # Try iTunes music art
            try:
                clean_t = re.sub(r'\(.*?\)|\[.*?\]', '', title).strip()
                query = f"{artist} {clean_t}".strip() if artist else clean_t
                q_enc = urllib.parse.quote(query)
                itunes_url = f"https://itunes.apple.com/search?term={q_enc}&media=music&limit=1"
                req = urllib.request.Request(itunes_url, headers={"User-Agent": "Mozilla/5.0"})
                with urllib.request.urlopen(req, timeout=2.0) as resp:
                    res_data = json.loads(resp.read().decode("utf-8"))
                    if res_data.get("resultCount", 0) > 0:
                        art = res_data["results"][0].get("artworkUrl100", "").replace("100x100bb", "400x400bb")
                        if art:
                            urllib.request.urlretrieve(art, CACHE_ART_PATH)
                            with open(CACHE_ART_KEY, "w", encoding="utf-8") as f:
                                f.write(track_key)
                            RESOLVED_ARTS[track_key] = f"file://{CACHE_ART_PATH}"
                            return
            except Exception:
                pass

            # Try YouTube search query
            try:
                q_enc = urllib.parse.quote(title.strip())
                yt_url = f"https://www.youtube.com/results?search_query={q_enc}"
                req = urllib.request.Request(yt_url, headers={"User-Agent": "Mozilla/5.0"})
                with urllib.request.urlopen(req, timeout=2.2) as resp:
                    html = resp.read().decode("utf-8", errors="ignore")
                    m = re.search(r'\"videoId\":\"([a-zA-Z0-9_-]{11})\"', html)
                    if m:
                        v_id = m.group(1)
                        thumb = f"https://i.ytimg.com/vi/{v_id}/hqdefault.jpg"
                        urllib.request.urlretrieve(thumb, CACHE_ART_PATH)
                        with open(CACHE_ART_KEY, "w", encoding="utf-8") as f:
                            f.write(track_key)
                        RESOLVED_ARTS[track_key] = f"file://{CACHE_ART_PATH}"
                        return
            except Exception:
                pass
    except Exception:
        pass
    finally:
        RESOLVING_ARTS.discard(track_key)

def format_time(seconds):
    try:
        s = max(0, int(seconds))
        mins = s // 60
        secs = s % 60
        return f"{mins}:{secs:02d}"
    except Exception:
        return "0:00"

def main():
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "seek" and len(sys.argv) > 2:
            target_sec = sys.argv[2]
            try:
                with open(SEEK_FILE, "w") as f:
                    f.write(str(target_sec))
            except Exception:
                pass
            subprocess.run(["playerctl", "position", str(target_sec)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            sys.exit(0)
        elif cmd in ("play-pause", "next", "previous"):
            subprocess.run(["playerctl", cmd], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            sys.exit(0)

    last_track_id = ""
    last_known_pos = 0.0
    last_update_time = time.time()

    while True:
        try:
            # Query active player
            proc = subprocess.run(
                ["playerctl", "metadata", "--format", "{{playerName}}:::{{title}}:::{{artist}}:::{{mpris:artUrl}}:::{{status}}:::{{position}}:::{{mpris:length}}:::{{xesam:url}}"],
                capture_output=True,
                text=True,
                timeout=1.2
            )
            raw = proc.stdout.strip()
            if not raw or ":::" not in raw:
                data = {
                    "available": False,
                    "playing": False,
                    "active": False,
                    "title": "",
                    "artist": "",
                    "art_url": "",
                    "position": 0,
                    "length": 100,
                    "position_str": "0:00",
                    "remaining_str": "-0:00",
                    "progress": 0.0
                }
                print(json.dumps(data), flush=True)
                time.sleep(1.0)
                continue

            parts = raw.split(":::")
            player = parts[0] if len(parts) > 0 else ""
            title = parts[1] if len(parts) > 1 else ""
            artist = parts[2] if len(parts) > 2 else ""
            art_url = parts[3] if len(parts) > 3 else ""
            status = parts[4] if len(parts) > 4 else "Stopped"
            pos_raw = parts[5] if len(parts) > 5 else ""
            len_raw = parts[6] if len(parts) > 6 else ""
            url = parts[7] if len(parts) > 7 else ""

            is_playing = (status.lower() == "playing")
            track_key = f"{title}_{artist}_{url}"
            is_browser = any(b in player.lower() for b in ["firefox", "zen", "chrome", "chromium", "brave"])

            # Check seek signal file
            if os.path.exists(SEEK_FILE):
                try:
                    with open(SEEK_FILE, "r") as f:
                        s_val = float(f.read().strip())
                    last_known_pos = s_val
                    last_update_time = time.time()
                    os.remove(SEEK_FILE)
                except Exception:
                    pass

            # Extract video ID from URL
            vid_id = None
            if url:
                m_vid = re.search(r'(?:v=|\/)([a-zA-Z0-9_-]{11})', url)
                if m_vid:
                    vid_id = m_vid.group(1)

            # Determine length in seconds
            len_sec = 0.0
            if len_raw:
                try:
                    v = float(len_raw)
                    len_sec = (v / 1000000.0) if v > 100000 else v
                except Exception:
                    pass

            if len_sec <= 0 and vid_id:
                if vid_id in CACHE_DURATIONS:
                    len_sec = float(CACHE_DURATIONS[vid_id])
                else:
                    threading.Thread(target=fetch_yt_duration, args=(vid_id,), daemon=True).start()

            if len_sec <= 0:
                len_sec = 180.0

            # Determine position in seconds
            native_pos = None
            if pos_raw:
                try:
                    p_val = float(pos_raw)
                    if is_browser:
                        if p_val > 100000:
                            native_pos = p_val / 1000000.0
                    else:
                        native_pos = (p_val / 1000000.0) if p_val > 100000 else p_val
                except Exception:
                    pass

            if track_key != last_track_id:
                last_track_id = track_key
                last_update_time = time.time()
                initial_pos = 0.0
                if url:
                    m_t = re.search(r'[?&]t=([0-9]+)s?', url)
                    if m_t:
                        initial_pos = float(m_t.group(1))
                if native_pos is not None:
                    last_known_pos = native_pos
                else:
                    last_known_pos = initial_pos
            else:
                now = time.time()
                dt = now - last_update_time
                last_update_time = now

                if native_pos is not None:
                    last_known_pos = native_pos
                elif is_playing:
                    last_known_pos += dt

            # Clamp position
            current_pos = min(len_sec, max(0.0, last_known_pos))
            rem_sec = max(0.0, len_sec - current_pos)
            progress = (current_pos / len_sec) if len_sec > 0 else 0.0

            # Resolve Artwork
            final_art = ""
            if track_key in RESOLVED_ARTS:
                final_art = RESOLVED_ARTS[track_key]
            else:
                # Check persistent cache file
                if os.path.exists(CACHE_ART_KEY) and os.path.exists(CACHE_ART_PATH):
                    try:
                        with open(CACHE_ART_KEY, "r", encoding="utf-8") as f:
                            if f.read().strip() == track_key and os.path.getsize(CACHE_ART_PATH) > 1000:
                                final_art = f"file://{CACHE_ART_PATH}"
                                RESOLVED_ARTS[track_key] = final_art
                    except Exception:
                        pass

                if not final_art and track_key not in RESOLVING_ARTS:
                    RESOLVING_ARTS.add(track_key)
                    threading.Thread(
                        target=resolve_cover_art_worker,
                        args=(art_url, title, artist, url, vid_id, track_key),
                        daemon=True
                    ).start()

                # Fallback to direct art_url or YouTube thumb while thread resolves
                if not final_art:
                    if art_url:
                        final_art = art_url
                    elif vid_id:
                        final_art = f"https://i.ytimg.com/vi/{vid_id}/hqdefault.jpg"

            pos_str = format_time(current_pos)
            rem_str = "-" + format_time(rem_sec)

            data = {
                "available": True,
                "playing": is_playing,
                "active": True,
                "title": title or "Sin reproducción",
                "artist": artist or ("Media Player" if is_browser else "Astraeus Music"),
                "art_url": final_art,
                "position": round(current_pos, 1),
                "length": round(len_sec, 1),
                "position_str": pos_str,
                "remaining_str": rem_str,
                "progress": round(progress, 4)
            }
            print(json.dumps(data), flush=True)

        except Exception as e:
            pass

        time.sleep(0.8)

if __name__ == "__main__":
    main()
