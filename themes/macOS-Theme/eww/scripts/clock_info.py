#!/usr/bin/env python3
"""
Lunita macOS Desktop Widgets - Sonoma Clock Provider
Formats time, dial data, city/timezone, and handles 12h/24h toggle.
"""

import sys
import os
import json
import time
import subprocess
from datetime import datetime

STATE_FILE = os.path.expanduser("~/.local/share/lunita/clock_state.json")

def get_mode():
    if not os.path.exists(STATE_FILE):
        return "12h"
    try:
        with open(STATE_FILE, "r") as f:
            return json.load(f).get("mode", "12h")
    except Exception:
        return "12h"

def set_mode(mode):
    os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
    with open(STATE_FILE, "w") as f:
        json.dump({"mode": mode}, f)

def get_clock_data():
    now = datetime.now()
    mode = get_mode()
    
    if mode == "12h":
        hour_int = now.hour % 12
        if hour_int == 0:
            hour_int = 12
        time_str = f"{hour_int}:{now.minute:02d}"
        ampm = "AM" if now.hour < 12 else "PM"
    else:
        time_str = f"{now.hour:02d}:{now.minute:02d}"
        ampm = "HRS"

    # Get local timezone or city
    try:
        tz_link = os.readlink("/etc/localtime")
        city = tz_link.split("/")[-1].replace("_", " ").upper()
    except Exception:
        city = "LOCAL"

    days_short = ["LUN", "MAR", "MIÉ", "JUE", "VIE", "SÁB", "DOM"]
    
    return {
        "time": time_str,
        "hours": f"{now.hour:02d}",
        "minutes": f"{now.minute:02d}",
        "seconds": f"{now.second:02d}",
        "ampm": ampm,
        "city": city,
        "weekday": days_short[now.weekday()],
        "day": str(now.day),
        "mode": mode
    }

def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "get"
    
    if cmd == "get":
        print(json.dumps(get_clock_data(), ensure_ascii=False))
        sys.stdout.flush()
    elif cmd == "toggle":
        curr = get_mode()
        new_mode = "24h" if curr == "12h" else "12h"
        set_mode(new_mode)
        data = get_clock_data()
        subprocess.run(["eww", "update", f"clock_data={json.dumps(data, ensure_ascii=False)}"], check=False)
        print(json.dumps(data, ensure_ascii=False))
        sys.stdout.flush()
    elif cmd == "watch":
        while True:
            try:
                print(json.dumps(get_clock_data(), ensure_ascii=False))
                sys.stdout.flush()
            except BrokenPipeError:
                break
            time.sleep(1)

if __name__ == "__main__":
    main()
