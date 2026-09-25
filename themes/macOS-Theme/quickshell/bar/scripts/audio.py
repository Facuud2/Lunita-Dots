#!/usr/bin/env python3
import sys, subprocess, json, re

def get_audio_info():
    res = {
        "volume": 50,
        "muted": False,
        "activeSink": "",
        "sinks": []
    }
    try:
        # Get volume & mute
        vol_out = subprocess.run(["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || pamixer --get-volume 2>/dev/null"], capture_output=True, text=True, timeout=2).stdout.strip()
        if "Volume:" in vol_out:
            parts = vol_out.split()
            if len(parts) >= 2:
                try:
                    res["volume"] = int(round(float(parts[1]) * 100))
                except:
                    pass
                res["muted"] = ("[MUTED]" in vol_out)
        elif vol_out.isdigit():
            res["volume"] = int(vol_out)

        # Get sinks from wpctl status
        st_out = subprocess.run(["wpctl", "status"], capture_output=True, text=True, timeout=2).stdout
        sinks_section = False
        for line in st_out.splitlines():
            if "Sinks:" in line:
                sinks_section = True
                continue
            if sinks_section:
                if any(k in line for k in ["Sources:", "Filters:", "Streams:", "Video", "Settings"]):
                    break
                m = re.search(r'([* ])\s+(\d+)\.\s+([^\[]+)(?:\[vol:\s*([\d.]+)\])?', line)
                if m:
                    is_default = (m.group(1) == '*')
                    sink_id = int(m.group(2))
                    raw_name = m.group(3).strip()
                    vol = float(m.group(4)) if m.group(4) else (res["volume"] / 100.0)
                    
                    # Clean up name for macOS aesthetic
                    clean_name = raw_name
                    if "Hune Fauna" in raw_name or "ANC" in raw_name:
                        clean_name = "Hune Fauna ANC"
                    elif "HDMI" in raw_name or "SMB2230N" in raw_name:
                        clean_name = "Monitor Audio (HDMI)"
                    elif "Ryzen" in raw_name or "IEC958" in raw_name or "analógico" in raw_name.lower():
                        clean_name = "Altavoces integrados"
                    
                    is_headphones = any(k in raw_name.lower() for k in ["anc", "head", "buds", "airpods", "fauna", "auricular"])
                    is_hdmi = any(k in raw_name.lower() for k in ["hdmi", "dp", "displayport", "monitor", "tv"])
                    
                    if is_default:
                        res["activeSink"] = clean_name
                    
                    res["sinks"].append({
                        "id": sink_id,
                        "name": clean_name,
                        "rawName": raw_name,
                        "isDefault": is_default,
                        "volume": int(round(vol * 100)),
                        "type": "headphones" if is_headphones else ("hdmi" if is_hdmi else "speaker")
                    })
    except Exception as e:
        pass
    return res

if __name__ == "__main__":
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "set-sink" and len(sys.argv) > 2:
            subprocess.run(["wpctl", "set-default", sys.argv[2]])
        elif cmd == "set-vol" and len(sys.argv) > 2:
            try:
                frac = f"{float(sys.argv[2]) / 100.0:.2f}"
                subprocess.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", frac])
            except:
                pass
        elif cmd == "toggle-mute":
            subprocess.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
    print(json.dumps(get_audio_info()))
