#!/usr/bin/env python3
"""
Lunita macOS Desktop Widgets - Calendar & Events Provider
Provides real-time date info and agenda/events stream for eww.
"""

import sys
import os
import json
import time
from datetime import datetime

EVENTS_FILE = os.path.expanduser("~/.local/share/lunita/events.json")

DEFAULT_EVENTS = [
    {
        "id": 1,
        "title": "⚽ Soccer practice",
        "time": "4 – 4:30 PM",
        "color": "orange",
        "done": False
    },
    {
        "id": 2,
        "title": "󰄲 Drop off Grandma's groceries",
        "time": "5:30 – 7 PM",
        "color": "green",
        "done": False
    },
    {
        "id": 3,
        "title": "󰑴 Homework help",
        "time": "7 – 8:30 PM",
        "color": "yellow",
        "done": False
    },
    {
        "id": 4,
        "title": "󰠮 Writing session with Anton",
        "time": "3 – 3:30 PM",
        "color": "red",
        "done": False
    },
    {
        "id": 5,
        "title": "󰘦 Lunita Dotfiles & Eww Widgets",
        "time": "9 – 11 PM",
        "color": "blue",
        "done": False
    }
]

def load_events():
    if not os.path.exists(EVENTS_FILE):
        os.makedirs(os.path.dirname(EVENTS_FILE), exist_ok=True)
        with open(EVENTS_FILE, "w", encoding="utf-8") as f:
            json.dump(DEFAULT_EVENTS, f, indent=2, ensure_ascii=False)
        return DEFAULT_EVENTS
    try:
        with open(EVENTS_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return DEFAULT_EVENTS

def save_events(events):
    os.makedirs(os.path.dirname(EVENTS_FILE), exist_ok=True)
    with open(EVENTS_FILE, "w", encoding="utf-8") as f:
        json.dump(events, f, indent=2, ensure_ascii=False)

def get_data():
    now = datetime.now()
    events = load_events()
    
    # Format weekday names in Spanish / English
    days_es = ["LUNES", "MARTES", "MIÉRCOLES", "JUEVES", "VIERNES", "SÁBADO", "DOMINGO"]
    months_es = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    weekday_name = days_es[now.weekday()]
    month_name = months_es[now.month - 1]
    
    # Active events (limit to top 4 for widget fit)
    active_events = [e for e in events if not e.get("done", False)]
    if not active_events:
        active_events = events[:4]
    
    data = {
        "weekday": weekday_name,
        "day": str(now.day),
        "month": month_name,
        "year": str(now.year),
        "full_date": f"{weekday_name.capitalize()} {now.day} de {month_name}",
        "events_count": len(events),
        "events": active_events[:4]
    }
    return data

def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "get"
    
    if cmd == "get":
        print(json.dumps(get_data(), ensure_ascii=False))
        sys.stdout.flush()
    elif cmd == "watch":
        while True:
            try:
                print(json.dumps(get_data(), ensure_ascii=False))
                sys.stdout.flush()
            except BrokenPipeError:
                break
            time.sleep(15)
    elif cmd == "toggle":
        if len(sys.argv) > 2:
            event_id = int(sys.argv[2])
            events = load_events()
            for ev in events:
                if ev.get("id") == event_id:
                    ev["done"] = not ev.get("done", False)
                    break
            save_events(events)
            # Notify eww
            print(json.dumps(get_data(), ensure_ascii=False))
            sys.stdout.flush()
    elif cmd == "add":
        if len(sys.argv) > 3:
            title = sys.argv[2]
            ev_time = sys.argv[3]
            color = sys.argv[4] if len(sys.argv) > 4 else "blue"
            events = load_events()
            new_id = max([e.get("id", 0) for e in events], default=0) + 1
            events.append({
                "id": new_id,
                "title": title,
                "time": ev_time,
                "color": color,
                "done": False
            })
            save_events(events)

if __name__ == "__main__":
    main()
