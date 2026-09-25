#!/usr/bin/env python3
import subprocess, json

def get_bluetooth():
    try:
        show = subprocess.run(["bluetoothctl", "show"], capture_output=True, text=True, timeout=2).stdout
        powered = "Powered: yes" in show
        paired_out = subprocess.run(["bluetoothctl", "devices", "Paired"], capture_output=True, text=True, timeout=2).stdout
        conn_out = subprocess.run(["bluetoothctl", "devices", "Connected"], capture_output=True, text=True, timeout=2).stdout
        conn_macs = {line.split()[1] for line in conn_out.strip().split("\n") if len(line.split()) >= 2 and line.split()[0] == "Device"}
        
        devices = []
        connected_device = ""
        for line in paired_out.strip().split("\n"):
            parts = line.split(" ", 2)
            if len(parts) >= 3 and parts[0] == "Device":
                mac, name = parts[1], parts[2]
                is_conn = mac in conn_macs
                if is_conn and not connected_device:
                    connected_device = name
                is_audio = any(k in name.lower() for k in ["anc", "head", "buds", "airpods", "fauna", "audio", "sound"])
                devices.append({"mac": mac, "name": name, "connected": is_conn, "isAudio": is_audio})
        return {"powered": powered, "connectedDevice": connected_device, "devices": devices}
    except Exception as e:
        return {"powered": False, "connectedDevice": "", "devices": []}

print(json.dumps(get_bluetooth()))
