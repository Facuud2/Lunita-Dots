#!/usr/bin/env python3
"""
🌙 Lunita-Dots — Notes & Calendar Agenda Provider
Synchronizes calendar events and daily schedule with quick notes and tasks.
Directly linked to ~/.config/lunita/calendar_events.json and ~/.config/lunita/notes.json.
"""

import json
import os
import sys
import time
from datetime import datetime, timedelta

CONFIG_DIR = os.path.expanduser("~/.config/lunita")
CALENDAR_FILE = os.path.join(CONFIG_DIR, "calendar_events.json")
NOTES_FILE = os.path.join(CONFIG_DIR, "notes.json")

DEFAULT_NOTES_DATA = {
    "tasks": [
        {
            "id": "t1",
            "title": "Revisar entregas y agenda",
            "tag": "Prioridad",
            "tag_color": "#007AFF",
            "done": False,
            "due": "Hoy"
        },
        {
            "id": "t2",
            "title": "Documentar cambios de Lunita-Dots",
            "tag": "Desarrollo",
            "tag_color": "#30D158",
            "done": True,
            "due": "Hoy"
        },
        {
            "id": "t3",
            "title": "Planificar sprint de proyectos",
            "tag": "Trabajo",
            "tag_color": "#AF52DE",
            "done": False,
            "due": "Mañana"
        }
    ],
    "notes_list": [],
    "notes": "• Recordar sincronizar calendario y widgets\n• Revisar métricas de salud\n• Deploy de actualización"
}

def load_calendar_data():
    if not os.path.exists(CALENDAR_FILE):
        return {}
    try:
        with open(CALENDAR_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}

def save_calendar_data(data):
    os.makedirs(CONFIG_DIR, exist_ok=True)
    try:
        with open(CALENDAR_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    except Exception:
        pass

def load_notes_data():
    os.makedirs(CONFIG_DIR, exist_ok=True)
    if not os.path.exists(NOTES_FILE):
        save_notes_data(DEFAULT_NOTES_DATA)
        return DEFAULT_NOTES_DATA.copy()
    try:
        with open(NOTES_FILE, "r", encoding="utf-8") as f:
            d = json.load(f)
            if "tasks" not in d:
                d["tasks"] = DEFAULT_NOTES_DATA["tasks"]
            if "notes" not in d:
                d["notes"] = DEFAULT_NOTES_DATA["notes"]
            if "notes_list" not in d:
                d["notes_list"] = []
            return d
    except Exception:
        return DEFAULT_NOTES_DATA.copy()

def save_notes_data(data):
    os.makedirs(CONFIG_DIR, exist_ok=True)
    try:
        with open(NOTES_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    except Exception:
        pass

def get_current_state():
    cal_data = load_calendar_data()
    notes_data = load_notes_data()

    now = datetime.now()
    today_str = now.strftime("%Y-%m-%d")
    tomorrow_str = (now + timedelta(days=1)).strftime("%Y-%m-%d")

    today_events = list(cal_data.get(today_str, []))
    
    # Check for upcoming events in the next 14 days
    upcoming_events = []
    for d_offset in range(1, 15):
        chk_dt = now + timedelta(days=d_offset)
        chk_str = chk_dt.strftime("%Y-%m-%d")
        if chk_str in cal_data:
            day_label = "Mañana" if d_offset == 1 else chk_dt.strftime("%d/%m")
            for ev in cal_data[chk_str]:
                ev_copy = dict(ev)
                ev_copy["date_str"] = chk_str
                ev_copy["day_label"] = day_label
                upcoming_events.append(ev_copy)

    # Determine currently active or upcoming event
    current_event = None
    is_active = False
    is_finishing_soon = False
    status_label = "Sin eventos hoy"
    time_left_str = "Día libre"

    if today_events:
        # Try finding current event by time
        cur_min_now = now.hour * 60 + now.minute
        for ev in today_events:
            t_str = ev.get("time", "")
            if "-" in t_str:
                parts = t_str.split("-")
                try:
                    s_h, s_m = [int(x) for x in parts[0].strip().split(":")]
                    e_h, e_m = [int(x) for x in parts[1].strip().split(":")]
                    start_min = s_h * 60 + s_m
                    end_min = e_h * 60 + e_m
                    if start_min <= cur_min_now <= end_min:
                        current_event = ev
                        is_active = True
                        rem = end_min - cur_min_now
                        status_label = "En curso"
                        time_left_str = f"Termina en {rem} min" if rem < 60 else f"Termina en {rem//60}h {rem%60}m"
                        if rem <= 15:
                            is_finishing_soon = True
                        break
                    elif cur_min_now < start_min and not current_event:
                        rem = start_min - cur_min_now
                        current_event = ev
                        status_label = "Hoy más tarde"
                        time_left_str = f"Comienza en {rem} min" if rem < 60 else f"En {rem//60}h {rem%60}m ({parts[0].strip()})"
                except Exception:
                    pass
        if not current_event:
            current_event = today_events[0]
            status_label = "Hoy"
            time_left_str = current_event.get("time", "Programado")
    elif upcoming_events:
        next_ev = upcoming_events[0]
        status_label = f"Próximo: {next_ev.get('day_label', 'Pronto')}"
        time_left_str = f"{next_ev.get('day_label')} · {next_ev.get('time', '')}"
        current_event = next_ev

    return {
        "title": "Notas",
        "subject": current_event.get("title", "Sin eventos") if current_event else "Sin eventos",
        "start": current_event.get("time", "") if current_event else "",
        "end": "",
        "room": current_event.get("category", "General") if current_event else "General",
        "code": "",
        "professor": "",
        "color": current_event.get("color", "#0A84FF") if current_event else "#0A84FF",
        "status_label": status_label,
        "time_left_str": time_left_str,
        "is_active": is_active,
        "is_finishing_soon": is_finishing_soon,
        "progress_pct": 50 if is_active else 0,
        "today_events": today_events,
        "upcoming_events": upcoming_events,
        "schedule": today_events if today_events else upcoming_events[:5],
        "tasks": notes_data.get("tasks", []),
        "notes": notes_data.get("notes", ""),
        "notes_list": notes_data.get("notes_list", [])
    }

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "get"
    cal_data = load_calendar_data()
    notes_data = load_notes_data()

    if action == "get":
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "add_calendar_event" and len(sys.argv) >= 3:
        # python3 timetable_provider.py add_calendar_event "Title" "18:00 - 20:00" "Trabajo" "#0A84FF" [date]
        title = sys.argv[2]
        time_str = sys.argv[3] if len(sys.argv) > 3 else "Todo el día"
        category = sys.argv[4] if len(sys.argv) > 4 else "General"
        color = sys.argv[5] if len(sys.argv) > 5 else "#0A84FF"
        target_date = sys.argv[6] if len(sys.argv) > 6 else datetime.now().strftime("%Y-%m-%d")

        ev_id = f"ev_{int(time.time())}"
        new_ev = {
            "id": ev_id,
            "title": title,
            "time": time_str,
            "category": category,
            "color": color
        }
        if target_date not in cal_data:
            cal_data[target_date] = []
        cal_data[target_date].append(new_ev)
        save_calendar_data(cal_data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "delete_calendar_event" and len(sys.argv) >= 3:
        ev_id = str(sys.argv[2])
        for d, ev_list in cal_data.items():
            cal_data[d] = [e for e in ev_list if str(e.get("id")) != ev_id]
        save_calendar_data(cal_data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "toggle_task" and len(sys.argv) >= 3:
        task_id = str(sys.argv[2])
        for t in notes_data.get("tasks", []):
            if str(t.get("id")) == task_id:
                t["done"] = not t.get("done", False)
                break
        save_notes_data(notes_data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "add_task" and len(sys.argv) >= 3:
        title = sys.argv[2]
        tag = sys.argv[3] if len(sys.argv) > 3 else "General"
        due = sys.argv[4] if len(sys.argv) > 4 else "Pendiente"
        color_map = {
            "General": "#30D158",
            "Trabajo": "#AF52DE",
            "Examen": "#FF9F0A",
            "Estudio": "#007AFF",
            "Prioridad": "#FA114F"
        }
        new_task = {
            "id": f"t_{int(time.time() * 1000)}",
            "title": title,
            "tag": tag,
            "tag_color": color_map.get(tag, "#007AFF"),
            "done": False,
            "due": due
        }
        notes_data.setdefault("tasks", []).insert(0, new_task)
        save_notes_data(notes_data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "delete_task" and len(sys.argv) >= 3:
        task_id = str(sys.argv[2])
        notes_data["tasks"] = [t for t in notes_data.get("tasks", []) if str(t.get("id")) != task_id]
        save_notes_data(notes_data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "set_notes" and len(sys.argv) >= 3:
        notes_data["notes"] = sys.argv[2]
        save_notes_data(notes_data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "add_note" and len(sys.argv) >= 4:
        # python3 timetable_provider.py add_note "Title" "Body" [date] [color]
        title = sys.argv[2]
        body = sys.argv[3]
        date_str = sys.argv[4] if len(sys.argv) > 4 else "Hoy"
        color = sys.argv[5] if len(sys.argv) > 5 else "#FCC603"
        new_note = {
            "id": f"n_{int(time.time() * 1000)}",
            "title": title,
            "body": body,
            "date": date_str,
            "color": color,
            "has_thumbnail": False
        }
        notes_data.setdefault("notes_list", []).insert(0, new_note)
        save_notes_data(notes_data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "delete_note" and len(sys.argv) >= 3:
        note_id = str(sys.argv[2])
        notes_data["notes_list"] = [n for n in notes_data.get("notes_list", []) if str(n.get("id")) != note_id]
        save_notes_data(notes_data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

    elif action == "update_note" and len(sys.argv) >= 4:
        # python3 timetable_provider.py update_note note_id title [body]
        note_id = str(sys.argv[2])
        new_title = sys.argv[3]
        new_body = sys.argv[4] if len(sys.argv) > 4 else ""
        for n in notes_data.get("notes_list", []):
            if str(n.get("id")) == note_id:
                n["title"] = new_title
                n["body"] = new_body
                break
        save_notes_data(notes_data)
        print(json.dumps(get_current_state(), ensure_ascii=False))

    else:
        print(json.dumps(get_current_state(), ensure_ascii=False))

if __name__ == "__main__":
    main()
