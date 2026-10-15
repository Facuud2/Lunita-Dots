#!/usr/bin/env python3
import sys
import subprocess
import json
import re
import signal

def get_audio_state():
    state = {
        "volume": 50,
        "muted": False,
        "sink": "Altavoces",
        "isHeadphones": False
    }
    try:
        vol_proc = subprocess.run(
            ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"],
            capture_output=True,
            text=True,
            timeout=1
        )
        vol_out = vol_proc.stdout.strip()
        if "Volume:" in vol_out:
            parts = vol_out.split()
            if len(parts) >= 2:
                try:
                    state["volume"] = int(round(float(parts[1]) * 100))
                except Exception:
                    pass
            state["muted"] = ("[MUTED]" in vol_out)
        elif vol_out.isdigit():
            state["volume"] = int(vol_out)

        st_proc = subprocess.run(
            ["wpctl", "status"],
            capture_output=True,
            text=True,
            timeout=1
        )
        sinks_section = False
        for line in st_proc.stdout.splitlines():
            if "Sinks:" in line:
                sinks_section = True
                continue
            if sinks_section:
                if any(k in line for k in ["Sources:", "Filters:", "Streams:", "Video", "Settings"]):
                    break
                m = re.search(r'([* ])\s+(\d+)\.\s+([^\[]+)', line)
                if m:
                    is_default = (m.group(1) == '*')
                    if is_default:
                        raw_name = m.group(3).strip()
                        clean_name = raw_name
                        if "Hune Fauna" in raw_name or "ANC" in raw_name:
                            clean_name = "Hune Fauna ANC"
                        elif "AirPods" in raw_name:
                            clean_name = "AirPods"
                        elif "HDMI" in raw_name or "SMB2230N" in raw_name:
                            clean_name = "Monitor Audio (HDMI)"
                        elif "Ryzen" in raw_name or "IEC958" in raw_name or "analógico" in raw_name.lower():
                            clean_name = "Altavoces integrados"
                        
                        is_hp = any(k in raw_name.lower() for k in ["anc", "head", "buds", "airpods", "fauna", "auricular", "headset", "headphones"])
                        state["sink"] = clean_name
                        state["isHeadphones"] = is_hp
                        break
    except Exception:
        pass
    return state

def main():
    pactl_proc = None

    def cleanup():
        nonlocal pactl_proc
        try:
            if pactl_proc and pactl_proc.poll() is None:
                pactl_proc.terminate()
                pactl_proc.wait(timeout=0.3)
        except Exception:
            pass

    import atexit
    atexit.register(cleanup)
    signal.signal(signal.SIGTERM, lambda s, f: sys.exit(0))
    signal.signal(signal.SIGINT, lambda s, f: sys.exit(0))

    last_state = get_audio_state()
    print(json.dumps(last_state))
    sys.stdout.flush()

    try:
        pactl_proc = subprocess.Popen(
            ["pactl", "subscribe"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            bufsize=1
        )
    except Exception:
        return

    while True:
        try:
            line = pactl_proc.stdout.readline()
            if not line:
                break
            
            lower_line = line.lower()
            if "change" in lower_line and ("sink" in lower_line or "server" in lower_line or "card" in lower_line):
                curr = get_audio_state()
                if (curr["volume"] != last_state["volume"]) or (curr["muted"] != last_state["muted"]):
                    print(json.dumps(curr))
                    sys.stdout.flush()
                    last_state = curr
                elif curr["sink"] != last_state["sink"] or curr["isHeadphones"] != last_state["isHeadphones"]:
                    print(json.dumps(curr))
                    sys.stdout.flush()
                    last_state = curr
        except (BrokenPipeError, IOError):
            break
        except Exception:
            break

    cleanup()

if __name__ == "__main__":
    main()
