#!/usr/bin/env python3
"""
🌙 Lunita-Dots — Health & Fitness Provider for macOS-style Health Widget
Manages daily steps, active calories, exercise minutes, and water hydration.
Supports manual modification, daily reset detection, and persistent JSON storage.
"""

import json
import os
import sys
from datetime import datetime

CONFIG_DIR = os.path.expanduser("~/.config/lunita")
DATA_FILE = os.path.join(CONFIG_DIR, "health_tracker.json")

DEFAULT_DATA = {
    "date": datetime.now().strftime("%Y-%m-%d"),
    "calories": 0,
    "calories_goal": 600,
    "exercise": 0,
    "exercise_goal": 30,
    "steps": 0,
    "steps_goal": 10000,
    "water": 0.0,
    "water_goal": 2.5,
    "history": [
        {"day": "L", "cal_pct": 0, "ex_pct": 0, "step_pct": 0},
        {"day": "M", "cal_pct": 0, "ex_pct": 0, "step_pct": 0},
        {"day": "M", "cal_pct": 0, "ex_pct": 0, "step_pct": 0},
        {"day": "J", "cal_pct": 0, "ex_pct": 0, "step_pct": 0},
        {"day": "V", "cal_pct": 0, "ex_pct": 0, "step_pct": 0},
        {"day": "S", "cal_pct": 0, "ex_pct": 0, "step_pct": 0},
        {"day": "D", "cal_pct": 0, "ex_pct": 0, "step_pct": 0}
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
            today_str = datetime.now().strftime("%Y-%m-%d")
            if data.get("date") != today_str:
                data["date"] = today_str
            for k, v in DEFAULT_DATA.items():
                if k not in data:
                    data[k] = v
            # Ensure history length is 7
            if len(data.get("history", [])) != 7:
                data["history"] = DEFAULT_DATA["history"]
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

def update_history_for_today(data):
    cur_weekday = datetime.now().weekday()  # 0 = Monday, 6 = Sunday
    cal_goal = max(1, data.get("calories_goal", 600))
    ex_goal = max(1, data.get("exercise_goal", 30))
    step_goal = max(1, data.get("steps_goal", 10000))

    cal_pct = int(min(150, round((data.get("calories", 0) / cal_goal) * 100)))
    ex_pct = int(min(150, round((data.get("exercise", 0) / ex_goal) * 100)))
    step_pct = int(min(150, round((data.get("steps", 0) / step_goal) * 100)))

    history = data.get("history", [])
    if 0 <= cur_weekday < len(history):
        history[cur_weekday]["cal_pct"] = cal_pct
        history[cur_weekday]["ex_pct"] = ex_pct
        history[cur_weekday]["step_pct"] = step_pct
    data["history"] = history

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "get"
    data = load_data()

    if action == "get":
        print(json.dumps(data, ensure_ascii=False))

    elif action == "reset":
        data = {
            "date": datetime.now().strftime("%Y-%m-%d"),
            "calories": 0,
            "calories_goal": 600,
            "exercise": 0,
            "exercise_goal": 30,
            "steps": 0,
            "steps_goal": 10000,
            "water": 0.0,
            "water_goal": 2.5,
            "history": [
                {"day": "L", "cal_pct": 0, "ex_pct": 0, "step_pct": 0},
                {"day": "M", "cal_pct": 0, "ex_pct": 0, "step_pct": 0},
                {"day": "M", "cal_pct": 0, "ex_pct": 0, "step_pct": 0},
                {"day": "J", "cal_pct": 0, "ex_pct": 0, "step_pct": 0},
                {"day": "V", "cal_pct": 0, "ex_pct": 0, "step_pct": 0},
                {"day": "S", "cal_pct": 0, "ex_pct": 0, "step_pct": 0},
                {"day": "D", "cal_pct": 0, "ex_pct": 0, "step_pct": 0}
            ]
        }
        save_data(data)
        print(json.dumps(data, ensure_ascii=False))

    elif action == "set_metrics" and len(sys.argv) >= 6:
        # python3 health_tracker_provider.py set_metrics <calories> <exercise> <steps> <water>
        try:
            data["calories"] = max(0, int(float(sys.argv[2])))
            data["exercise"] = max(0, int(float(sys.argv[3])))
            data["steps"] = max(0, int(float(sys.argv[4])))
            data["water"] = max(0.0, round(float(sys.argv[5]), 2))
            update_history_for_today(data)
            save_data(data)
        except Exception:
            pass
        print(json.dumps(data, ensure_ascii=False))

    elif action == "set" and len(sys.argv) >= 4:
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
            update_history_for_today(data)
            save_data(data)
        except Exception:
            pass
        print(json.dumps(data, ensure_ascii=False))

    elif action == "set_day_pct" and len(sys.argv) >= 4:
        # python3 health_tracker_provider.py set_day_pct <day_idx 0-6> <cal_pct>
        try:
            idx = int(sys.argv[2])
            pct = max(0, int(float(sys.argv[3])))
            if 0 <= idx < len(data.get("history", [])):
                data["history"][idx]["cal_pct"] = pct
                save_data(data)
        except Exception:
            pass
        print(json.dumps(data, ensure_ascii=False))

    elif action == "adjust" and len(sys.argv) >= 4:
        metric = sys.argv[2].lower()
        delta_str = sys.argv[3]
        try:
            delta = float(delta_str)
            if metric in ("steps", "calories", "exercise"):
                data[metric] = max(0, int(data.get(metric, 0) + delta))
            elif metric in ("water",):
                data[metric] = max(0.0, round(data.get(metric, 0.0) + delta, 2))
            update_history_for_today(data)
            save_data(data)
        except Exception:
            pass
        print(json.dumps(data, ensure_ascii=False))

    else:
        print(json.dumps(data, ensure_ascii=False))

if __name__ == "__main__":
    main()
