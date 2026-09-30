#!/usr/bin/env python3
"""
🌙 Lunita-Dots — University (UNaB) & Workspace Notes Provider
Manages class schedules, university/work tasks, deadlines, and scratchpad notes.
Fully customizable with JSON persistence at ~/.config/lunita/unab_timetable.json.
"""

import json
import os
import sys
import time
from datetime import datetime, timedelta

CONFIG_DIR = os.path.expanduser("~/.config/lunita")
TIMETABLE_FILE = os.path.join(CONFIG_DIR, "unab_timetable.json")

DEFAULT_DATA = {
    "career": "Tecnicatura Universitaria en Programación",
    "university": "UNaB",
    "schedule": [
        {
            "day_index": 0,
            "day_name": "Lunes",
            "subject": "Algoritmos y Estructuras de Datos",
            "start": "18:00",
            "end": "22:00",
            "room": "Aula 104",
            "professor": "Prof. Martínez",
            "code": "AED-102"
        },
        {
            "day_index": 1,
            "day_name": "Martes",
            "subject": "Laboratorio de Computación I",
            "start": "18:30",
            "end": "21:30",
            "room": "Lab 2",
            "professor": "Prof. Gómez",
            "code": "LAB-101"
        },
        {
            "day_index": 2,
            "day_name": "Miércoles",
            "subject": "Bases de Datos Relacionales",
            "start": "18:00",
            "end": "22:00",
            "room": "Aula 201",
            "professor": "Prof. Rossi",
            "code": "BDR-201"
        },
        {
            "day_index": 3,
            "day_name": "Jueves",
            "subject": "Programación Web",
            "start": "18:30",
            "end": "22:00",
            "room": "Lab 1",
            "professor": "Prof. Fernández",
            "code": "WEB-103"
        },
        {
            "day_index": 4,
            "day_name": "Viernes",
            "subject": "Sistemas Operativos y Redes",
            "start": "18:00",
            "end": "21:00",
            "room": "Aula 105",
            "professor": "Prof. Díaz",
            "code": "SOR-104"
        }
    ],
    "tasks": [
        {
            "id": "t1",
            "title": "TP2 Árboles y Grafos",
            "tag": "UNaB",
            "tag_color": "#007AFF",
            "done": False,
            "due": "Viernes"
        },
        {
            "id": "t2",
            "title": "Revisión Pull Request #14",
            "tag": "Trabajo",
            "tag_color": "#AF52DE",
            "done": True,
            "due": "Hoy"
        },
        {
            "id": "t3",
            "title": "Estudiar Parcial BD",
            "tag": "Examen",
            "tag_color": "#FF9F0A",
            "done": False,
            "due": "Lunes"
        },
        {
            "id": "t4",
            "title": "Documentar API endpoints",
            "tag": "Trabajo",
            "tag_color": "#AF52DE",
            "done": False,
            "due": "Mañana"
        }
    ],
    "notes": "• Llevar resumen de Algoritmos\n• Consultar índices en PostgreSQL\n• Deploy sprint 3 a staging"
}

def load_data():
    os.makedirs(CONFIG_DIR, exist_ok=True)
    if not os.path.exists(TIMETABLE_FILE):
        save_data(DEFAULT_DATA)
        return DEFAULT_DATA.copy()
    try:
        with open(TIMETABLE_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            # Ensure keys exist
            if "tasks" not in data:
                data["tasks"] = DEFAULT_DATA["tasks"]
            if "notes" not in data:
                data["notes"] = DEFAULT_DATA["notes"]
            if "schedule" not in data:
                data["schedule"] = DEFAULT_DATA["schedule"]
            return data
    except Exception:
        return DEFAULT_DATA.copy()

def save_data(data):
    os.makedirs(CONFIG_DIR, exist_ok=True)
    try:
        with open(TIMETABLE_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    except Exception:
        pass

def format_duration(minutes):
    if minutes < 60:
        return f"{int(minutes)}m"
    hours = int(minutes // 60)
    mins = int(minutes % 60)
    if mins == 0:
        return f"{hours}h"
    return f"{hours}h {mins}m"

def get_current_state():
    data = load_data()
    schedule = data.get("schedule", [])
    now = datetime.now()
    cur_weekday = now.weekday()  # 0 = Monday, 6 = Sunday

    days_map = {}
    for item in schedule:
        days_map[item["day_index"]] = item

    current_class = None
    is_active = False
    is_finishing_soon = False
    time_left_str = ""
    status_label = "Sin clases hoy"
    progress_pct = 0

    # 1. Check if today has a class
    today_class = days_map.get(cur_weekday)
    if today_class:
        try:
            start_parts = [int(p) for p in today_class["start"].split(":")]
            end_parts = [int(p) for p in today_class["end"].split(":")]
            start_dt = now.replace(hour=start_parts[0], minute=start_parts[1], second=0, microsecond=0)
            end_dt = now.replace(hour=end_parts[0], minute=end_parts[1], second=0, microsecond=0)

            if start_dt <= now <= end_dt:
                is_active = True
                status_label = "En curso"
                total_duration = (end_dt - start_dt).total_seconds() / 60
                elapsed = (now - start_dt).total_seconds() / 60
                rem = (end_dt - now).total_seconds() / 60
                progress_pct = int(min(100, max(0, (elapsed / total_duration) * 100))) if total_duration > 0 else 0
                time_left_str = f"Termina en {format_duration(rem)}"
                if 0 < rem <= 15:
                    is_finishing_soon = True
                current_class = today_class
            elif now < start_dt:
                status_label = "Hoy más tarde"
                rem = (start_dt - now).total_seconds() / 60
                time_left_str = f"Comienza en {format_duration(rem)}"
                current_class = today_class
        except Exception:
            pass

    # 2. Upcoming class search
    if not current_class:
        for offset in range(1, 8):
            target_day = (cur_weekday + offset) % 7
            if target_day in days_map:
                c = days_map[target_day]
                day_name = c["day_name"]
                if offset == 1:
                    status_label = "Próxima: Mañana"
                    time_left_str = f"Mañana a las {c['start']}"
                else:
                    status_label = f"Próxima: {day_name}"
                    time_left_str = f"{day_name} a las {c['start']}"
                current_class = c
                break

    if not current_class and schedule:
        current_class = schedule[0]
        status_label = f"Próxima: {current_class['day_name']}"
        time_left_str = f"{current_class['day_name']} a las {current_class['start']}"

    return {
        "university": data.get("university", "UNaB"),
        "career": data.get("career", "Tecnicatura en Programación"),
        "subject": current_class["subject"] if current_class else "Sin actividades",
        "code": current_class.get("code", "") if current_class else "",
        "room": current_class.get("room", "") if current_class else "",
        "professor": current_class.get("professor", "") if current_class else "",
        "start": current_class.get("start", "") if current_class else "",
        "end": current_class.get("end", "") if current_class else "",
        "status_label": status_label,
        "time_left_str": time_left_str,
        "is_active": is_active,
        "is_finishing_soon": is_finishing_soon,
        "progress_pct": progress_pct,
        "schedule": schedule,
        "tasks": data.get("tasks", []),
        "notes": data.get("notes", "")
    }

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "get"
    data = load_data()

    if action == "get":
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "toggle_task" and len(sys.argv) >= 3:
        task_id = sys.argv[2]
        tasks = data.get("tasks", [])
        for t in tasks:
            if str(t.get("id")) == str(task_id):
                t["done"] = not t.get("done", False)
                break
        data["tasks"] = tasks
        save_data(data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "add_task" and len(sys.argv) >= 3:
        # python3 timetable_provider.py add_task "Title" "Tag" "Due"
        title = sys.argv[2]
        tag = sys.argv[3] if len(sys.argv) > 3 else "UNaB"
        due = sys.argv[4] if len(sys.argv) > 4 else "Pendiente"
        
        tag_colors = {
            "UNaB": "#007AFF",
            "Trabajo": "#AF52DE",
            "Examen": "#FF9F0A",
            "Proyecto": "#30D158"
        }
        new_task = {
            "id": f"t_{int(time.time() * 1000)}",
            "title": title,
            "tag": tag,
            "tag_color": tag_colors.get(tag, "#007AFF"),
            "done": False,
            "due": due
        }
        tasks = data.get("tasks", [])
        tasks.insert(0, new_task)
        data["tasks"] = tasks
        save_data(data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "delete_task" and len(sys.argv) >= 3:
        task_id = sys.argv[2]
        tasks = [t for t in data.get("tasks", []) if str(t.get("id")) != str(task_id)]
        data["tasks"] = tasks
        save_data(data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "set_notes" and len(sys.argv) >= 3:
        notes_text = sys.argv[2]
        data["notes"] = notes_text
        save_data(data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

if __name__ == "__main__":
    main()
