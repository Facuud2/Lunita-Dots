#!/usr/bin/env python3
"""
🌙 Lunita-Dots — Health & Fitness Provider for macOS-style Health Widget
Manages daily steps, active calories, exercise minutes, and water hydration.
Supports manual modification, daily reset detection, and persistent JSON storage.
"""

import os
import sys
import json
from datetime import datetime

CONFIG_DIR = os.path.expanduser("~/.config/lunita")
DATA_FILE = os.path.join(CONFIG_DIR, "health_tracker.json")

DEFAULT_DATA = {
    "date": datetime.now().strftime("%Y-%m-%d"),
    "calories": 540,
    "calories_goal": 600,
    "exercise": 35,
    "exercise_goal": 30,
    "steps": 8450,
    "steps_goal": 10000,
    "water": 2.1,
    "water_goal": 2.5,
    "history": [
        {"day": "L", "cal_pct": 95, "ex_pct": 100, "step_pct": 88},
        {"day": "M", "cal_pct": 90, "ex_pct": 115, "step_pct": 85},
        {"day": "M", "cal_pct": 80, "ex_pct": 70,  "step_pct": 75},
        {"day": "J", "cal_pct": 105, "ex_pct": 120, "step_pct": 100},
        {"day": "V", "cal_pct": 88, "ex_pct": 90,  "step_pct": 82},
        {"day": "S", "cal_pct": 110, "ex_pct": 130, "step_pct": 105},
        {"day": "D", "cal_pct": 90, "ex_pct": 100, "step_pct": 84}
    ]
}

def load_data():
    os.makedirs(CONFIG_DIR, exist_ok=True)
    if not os.path.exists(DATA_FILE):
        save_data(DEFAULT_DATA)
        return DEFAULT_DATA.copy()
    try:
        with open(DATA_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            # Check for new day
            today_str = datetime.now().strftime("%Y-%m-%d")
            if data.get("date") != today_str:
                data["date"] = today_str
                # Preserve goals, but optionally can reset or keep current
            for k, v in DEFAULT_DATA.items():
                if k not in data:
                    data[k] = v
            return data
    except Exception:
        return DEFAULT_DATA.copy()

def save_data(data):
    os.makedirs(CONFIG_DIR, exist_ok=True)
    try:
        with open(DATA_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    except Exception:
        pass

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "get"
    data = load_data()

    if action == "get":
        print(json.dumps(data, ensure_ascii=False))

    elif action == "set" and len(sys.argv) >= 4:
        # python3 health_tracker_provider.py set steps 9200
        metric = sys.argv[2].lower()
        val_str = sys.argv[3]
        try:
            if metric in ("steps", "calories", "exercise"):
                data[metric] = max(0, int(float(val_str)))
            elif metric in ("water",):
                data[metric] = max(0.0, round(float(val_str), 2))
            elif metric in ("steps_goal", "calories_goal", "exercise_goal"):
                data[metric] = max(1, int(float(val_str)))
            elif metric in ("water_goal",):
                data[metric] = max(0.1, round(float(val_str), 2))
            save_data(data)
        except Exception:
            pass
        print(json.dumps(data, ensure_ascii=False))

    elif action == "adjust" and len(sys.argv) >= 4:
        # python3 health_tracker_provider.py adjust steps +500
        metric = sys.argv[2].lower()
        delta_str = sys.argv[3]
        try:
            delta = float(delta_str)
            if metric in ("steps", "calories", "exercise"):
                data[metric] = max(0, int(data.get(metric, 0) + delta))
            elif metric in ("water",):
                data[metric] = max(0.0, round(data.get(metric, 0.0) + delta, 2))
            save_data(data)
        except Exception:
            pass
        print(json.dumps(data, ensure_ascii=False))

    else:
        print(json.dumps(data, ensure_ascii=False))

if __name__ == "__main__":
    main()
