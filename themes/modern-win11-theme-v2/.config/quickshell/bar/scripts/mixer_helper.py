#!/usr/bin/env python3
import sys
import subprocess
import re
import json

def get_streams():
    try:
        proc = subprocess.run(["pactl", "list", "sink-inputs"], capture_output=True, text=True, timeout=2.0)
        raw = proc.stdout
    except Exception:
        return []

    streams = []
    blocks = raw.split("Sink Input #")
    for b in blocks[1:]:
        lines = b.split("\n")
        input_id = lines[0].strip()
        app_name = ""
        media_name = ""
        volume = 100
        muted = False

        for line in lines:
            line_str = line.strip()
            if line_str.startswith("application.name ="):
                app_name = line_str.split("=", 1)[1].strip().strip('\"')
            elif line_str.startswith("media.name ="):
                media_name = line_str.split("=", 1)[1].strip().strip('\"')
            elif line_str.startswith("Mute:"):
                muted = ("yes" in line_str.lower())
            elif line_str.startswith("Volume:"):
                m_vol = re.search(r"(\d+)%", line_str)
                if m_vol:
                    volume = int(m_vol.group(1))

        if app_name or media_name:
            low = (app_name + " " + media_name).lower()
            icon = "󰕾"
            if "zen" in low or "firefox" in low or "chrome" in low or "browser" in low:
                icon = "󰈹"
            elif "spotify" in low or "music" in low:
                icon = "󰝚"
            elif "discord" in low or "vesktop" in low:
                icon = "󰙯"
            elif "telegram" in low:
                icon = "󰉍"
            elif "antigravity" in low:
                icon = "󰚩"
            elif "vlc" in low or "mpv" in low or "video" in low:
                icon = "󰕼"

            streams.append({
                "id": input_id,
                "name": app_name or "Audio Stream",
                "title": media_name or app_name or "Stream",
                "volume": volume,
                "muted": muted,
                "icon": icon
            })
    return streams

def main():
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "set-volume" and len(sys.argv) >= 4:
            s_id = sys.argv[2]
            vol = sys.argv[3]
            subprocess.run(["pactl", "set-sink-input-volume", str(s_id), f"{vol}%"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            sys.exit(0)
        elif cmd == "toggle-mute" and len(sys.argv) >= 3:
            s_id = sys.argv[2]
            subprocess.run(["pactl", "set-sink-input-mute", str(s_id), "toggle"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            sys.exit(0)

    print(json.dumps(get_streams()))

if __name__ == "__main__":
    main()
