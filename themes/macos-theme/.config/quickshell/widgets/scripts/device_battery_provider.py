#!/usr/bin/env python3
"""
🌙 Lunita-Dots — Real Connected Devices Battery Provider
Only discovers and reports currently connected devices that possess a battery
(such as Bluetooth headphones, mobile phones, mice, keyboards, or internal laptop battery).
"""

import glob
import json
import os
import re
import subprocess
import sys
from datetime import datetime

def get_connected_battery_devices():
    devices = []
    seen = set()

    # 1. Internal laptop battery (only if a real hardware battery exists)
    for bat_path in glob.glob("/sys/class/power_supply/BAT*"):
        try:
            cap_file = os.path.join(bat_path, "capacity")
            stat_file = os.path.join(bat_path, "status")
            if os.path.exists(cap_file):
                with open(cap_file, "r") as f:
                    cap = int(f.read().strip())
                status = "Discharging"
                if os.path.exists(stat_file):
                    with open(stat_file, "r") as f:
                        status = f.read().strip()

                devices.append({
                    "id": "pc_battery",
                    "name": "Batería Mac / Laptop",
                    "percent": cap,
                    "type": "laptop",
                    "icon": "󰌢",
                    "charging": status.lower() == "charging",
                    "connected": True
                })
                seen.add("pc_battery")
                break
        except Exception:
            pass

    # 2. Bluetooth connected devices with battery reported by bluetoothctl
    try:
        out = subprocess.check_output(
            ["bluetoothctl", "devices", "Connected"],
            text=True,
            stderr=subprocess.DEVNULL
        )
        for line in out.strip().splitlines():
            m = re.match(r"^Device\s+([0-9A-Fa-f:]+)\s+(.+)$", line.strip())
            if not m:
                continue
            mac, name = m.group(1), m.group(2)
            try:
                info = subprocess.check_output(
                    ["bluetoothctl", "info", mac],
                    text=True,
                    stderr=subprocess.DEVNULL
                )
                bat_m = re.search(r"Battery Percentage:\s*(?:0x[0-9a-fA-F]+\s*)?\(?(\d+)\)?", info)
                if bat_m:
                    percent = int(bat_m.group(1))
                    dev_type = "headset"
                    icon = "󰋋"
                    info_l = info.lower()
                    name_l = name.lower()

                    if "phone" in info_l or "phone" in name_l or "iphone" in name_l or "redmi" in name_l or "galaxy" in name_l:
                        dev_type = "phone"
                        icon = ""
                    elif "mouse" in info_l or "mouse" in name_l or "trackpad" in name_l:
                        dev_type = "mouse"
                        icon = "󰍽"
                    elif "keyboard" in info_l or "keyboard" in name_l or "teclado" in name_l:
                        dev_type = "keyboard"
                        icon = "󰌌"
                    elif "gamepad" in info_l or "joystick" in info_l or "controller" in name_l:
                        dev_type = "gamepad"
                        icon = "󰊴"
                    elif "ipad" in name_l or "tablet" in name_l:
                        dev_type = "tablet"
                        icon = ""
                    elif "headset" in info_l or "audio" in info_l or "anc" in name_l or "buds" in name_l or "airpods" in name_l:
                        dev_type = "headset"
                        icon = "󰋋"

                    key = mac.replace(":", "_").lower()
                    devices.append({
                        "id": key,
                        "name": name,
                        "percent": percent,
                        "type": dev_type,
                        "icon": icon,
                        "charging": False,
                        "connected": True
                    })
                    seen.add(key)
                    seen.add(name_l)
            except Exception:
                pass
    except Exception:
        pass

    # 3. UPower devices (covers devices reporting via BlueZ D-Bus/UPower)
    try:
        up_paths = subprocess.check_output(
            ["upower", "-e"],
            text=True,
            stderr=subprocess.DEVNULL
        ).strip().splitlines()

        for p in up_paths:
            p = p.strip()
            if not p or "displaydevice" in p.lower():
                continue
            try:
                info = subprocess.check_output(
                    ["upower", "-i", p],
                    text=True,
                    stderr=subprocess.DEVNULL
                )
                model = ""
                percentage = None
                state = ""
                icon_name = ""

                for line in info.splitlines():
                    line = line.strip()
                    if line.startswith("model:"):
                        model = line.split(":", 1)[1].strip()
                    elif line.startswith("percentage:"):
                        p_str = line.split(":", 1)[1].strip().replace("%", "")
                        try:
                            percentage = int(float(p_str))
                        except ValueError:
                            pass
                    elif line.startswith("state:"):
                        state = line.split(":", 1)[1].strip()
                    elif line.startswith("icon-name:"):
                        icon_name = line.split(":", 1)[1].strip().strip("'\"")

                if percentage is not None and model and model.lower() not in seen:
                    dev_type = "headset"
                    icon = "󰋋"
                    m_lower = model.lower()
                    i_lower = icon_name.lower()

                    if "mouse" in i_lower or "mouse" in m_lower:
                        dev_type = "mouse"
                        icon = "󰍽"
                    elif "keyboard" in i_lower or "keyboard" in m_lower:
                        dev_type = "keyboard"
                        icon = "󰌌"
                    elif "phone" in i_lower or "phone" in m_lower:
                        dev_type = "phone"
                        icon = ""
                    elif "headset" in i_lower or "headphone" in i_lower or "anc" in m_lower:
                        dev_type = "headset"
                        icon = "󰋋"
                    elif "battery" in p.lower() and "display" not in p.lower():
                        dev_type = "laptop"
                        icon = "󰌢"

                    devices.append({
                        "id": model.replace(" ", "_").lower(),
                        "name": model,
                        "percent": percentage,
                        "type": dev_type,
                        "icon": icon,
                        "charging": state.lower() == "charging",
                        "connected": True
                    })
                    seen.add(model.lower())
            except Exception:
                pass
    except Exception:
        pass

    now_str = datetime.now().strftime("%H:%M")
    return {
        "devices": devices,
        "last_sync": now_str
    }

def main():
    data = get_connected_battery_devices()
    print(json.dumps(data, ensure_ascii=False))

if __name__ == "__main__":
    main()
