#!/usr/bin/env python3
import sys
import subprocess
import json
import re

def get_audio_state():
    state = {
        "type": "volume",
        "volume": 50,
        "muted": False,
        "sink": "Altavoces",
        "isHeadphones": False
    }
    try:
        # 1. Obtener volumen y mute de wpctl
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

        # 2. Obtener nombre del Sink activo
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
    # Modo consulta única
    if len(sys.argv) > 1 and sys.argv[1] == "get":
        print(json.dumps(get_audio_state()))
        sys.stdout.flush()
        return

    # Estado inicial
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
            
            # Filtrar estrictamente solo eventos de cambio en 'sink'
            # (ignorar server, client, module, sample-cache, sink-input, source, etc.)
            lower_line = line.lower()
            if "change" in lower_line and "sink #" in lower_line:
                curr = get_audio_state()
                # Emitir ÚNICAMENTE si el volumen o el estado de mute realmente cambiaron
                if (curr["volume"] != last_state["volume"]) or (curr["muted"] != last_state["muted"]):
                    print(json.dumps(curr))
                    sys.stdout.flush()
                    last_state = curr
                elif curr["sink"] != last_state["sink"] or curr["isHeadphones"] != last_state["isHeadphones"]:
                    last_state = curr
        except Exception:
            break

if __name__ == "__main__":
    main()
