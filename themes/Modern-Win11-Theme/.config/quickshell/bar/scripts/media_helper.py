#!/usr/bin/env python3
import sys
import os
import subprocess
import json
import re
import time
import urllib.request
import threading

CACHE_DURATIONS = {}
FETCHING = set()

SEEK_FILE = "/tmp/lunita_media_seek.txt"

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
    last_status = "Stopped"

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

            # Determine length in seconds
            len_sec = 0.0
            if len_raw:
                try:
                    v = float(len_raw)
                    len_sec = (v / 1000000.0) if v > 100000 else v
                except Exception:
                    pass

            # If browser/YouTube has no native length, resolve it
            vid_id = None
            if url:
                m_vid = re.search(r'(?:v=|\/)([a-zA-Z0-9_-]{11})', url)
                if m_vid:
                    vid_id = m_vid.group(1)

            if len_sec <= 0 and vid_id:
                if vid_id in CACHE_DURATIONS:
                    len_sec = float(CACHE_DURATIONS[vid_id])
                else:
                    threading.Thread(target=fetch_yt_duration, args=(vid_id,), daemon=True).start()

            if len_sec <= 0:
                len_sec = 180.0  # graceful default fallback

            # Determine position in seconds
            native_pos = None
            if pos_raw:
                try:
                    p_val = float(pos_raw)
                    if is_browser:
                        # Browsers frequently send microsecond stubs (< 1000)
                        if p_val > 100000:
                            native_pos = p_val / 1000000.0
                    else:
                        native_pos = (p_val / 1000000.0) if p_val > 100000 else p_val
                except Exception:
                    pass

            if track_key != last_track_id:
                # Track changed
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

            pos_str = format_time(current_pos)
            rem_str = "-" + format_time(rem_sec)

            data = {
                "available": True,
                "playing": is_playing,
                "active": True,
                "title": title or "Sin reproducción",
                "artist": artist or "Media Player",
                "art_url": art_url,
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
