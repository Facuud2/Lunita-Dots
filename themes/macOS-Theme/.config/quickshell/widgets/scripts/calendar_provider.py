#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — Calendar Events Provider for Quickshell Widgets
# Manages Android / iOS style event scheduling, date queries & notifications
# ==============================================================================

import os
import sys
import json
import datetime
import calendar

EVENTS_FILE = os.path.expanduser("~/.config/lunita/calendar_events.json")

def get_default_events(year, month, day):
    # Genera eventos de ejemplo para el día actual y días cercanos
    today_str = f"{year:04d}-{month:02d}-{day:02d}"
    
    # Calcular mañana
    today_date = datetime.date(year, month, day)
    tomorrow_date = today_date + datetime.timedelta(days=1)
    tomorrow_str = tomorrow_date.strftime("%Y-%m-%d")
    
    in_three_days = today_date + datetime.timedelta(days=3)
    in_three_days_str = in_three_days.strftime("%Y-%m-%d")

    return {
        today_str: [
            {
                "id": "ev_1",
                "title": "Reunión de planificación",
                "time": "15:00 - 16:00",
                "category": "Trabajo",
                "color": "#0A84FF"
            },
            {
                "id": "ev_2",
                "title": "Revisión de Lunita-Dots",
                "time": "18:30 - 19:30",
                "category": "Desarrollo",
                "color": "#30D158"
            }
        ],
        tomorrow_str: [
            {
                "id": "ev_3",
                "title": "Presentación de diseño",
                "time": "11:00 - 12:00",
                "category": "Diseño",
                "color": "#FF9F0A"
            }
        ],
        in_three_days_str: [
            {
                "id": "ev_4",
                "title": "Cena con amigos",
                "time": "21:00",
                "category": "Personal",
                "color": "#BF5AF2"
            }
        ]
    }

def load_events():
    now = datetime.datetime.now()
    if not os.path.exists(EVENTS_FILE):
        os.makedirs(os.path.dirname(EVENTS_FILE), exist_ok=True)
        defaults = get_default_events(now.year, now.month, now.day)
        save_events(defaults)
        return defaults
    
    try:
        with open(EVENTS_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            return data if isinstance(data, dict) else {}
    except Exception:
        return {}

def save_events(events):
    os.makedirs(os.path.dirname(EVENTS_FILE), exist_ok=True)
    try:
        with open(EVENTS_FILE, "w", encoding="utf-8") as f:
            json.dump(events, f, ensure_ascii=False, indent=2)
    except Exception:
        pass

def get_month_data(year=None, month=None):
    now = datetime.datetime.now()
    if year is None: year = now.year
    if month is None: month = now.month

    events = load_events()

    months = ['ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
              'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE']
    days = ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO', 'DOMINGO']

    cal = calendar.Calendar(firstweekday=0) # Lunes = 0
    m_weeks = cal.monthdayscalendar(year, month)

    # Identificar días con eventos en este mes
    events_by_day = {}
    for d in range(1, 32):
        d_str = f"{year:04d}-{month:02d}-{d:02d}"
        if d_str in events and len(events[d_str]) > 0:
            events_by_day[str(d)] = events[d_str]

    weeks = []
    for w in m_weeks:
        week_days = []
        for d in w:
            d_str = str(d) if d != 0 else ""
            has_ev = d_str in events_by_day
            ev_list = events_by_day.get(d_str, [])
            week_days.append({
                "day": d_str,
                "in_month": d != 0,
                "is_today": (d == now.day and month == now.month and year == now.year),
                "has_events": has_ev,
                "events_count": len(ev_list),
                "dot_color": ev_list[0].get("color", "#0A84FF") if ev_list else ""
            })
        weeks.append(week_days)

    return {
        "month_name": months[month - 1],
        "year": str(year),
        "month_num": month,
        "today": str(now.day),
        "weekday": days[now.weekday()],
        "weeks": weeks,
        "all_events": events
    }

def main():
    now = datetime.datetime.now()
    action = sys.argv[1] if len(sys.argv) > 1 else "get"

    if action == "get":
        data = get_month_data(now.year, now.month)
        print(json.dumps(data))

    elif action == "events_for_day":
        date_str = sys.argv[2] if len(sys.argv) > 2 else now.strftime("%Y-%m-%d")
        events = load_events()
        day_events = events.get(date_str, [])
        print(json.dumps({
            "date": date_str,
            "events": day_events,
            "count": len(day_events)
        }))

    elif action == "add":
        # python3 calendar_provider.py add 2026-09-29 "15:00" "Reunión" "Trabajo" "#0A84FF"
        if len(sys.argv) >= 5:
            date_str = sys.argv[2]
            time_str = sys.argv[3]
            title_str = sys.argv[4]
            category = sys.argv[5] if len(sys.argv) > 5 else "General"
            color = sys.argv[6] if len(sys.argv) > 6 else "#0A84FF"

            events = load_events()
            if date_str not in events:
                events[date_str] = []
            
            import uuid
            new_ev = {
                "id": "ev_" + str(uuid.uuid4())[:8],
                "title": title_str,
                "time": time_str,
                "category": category,
                "color": color
            }
            events[date_str].append(new_ev)
            save_events(events)

            data = get_month_data(now.year, now.month)
            print(json.dumps(data))

    elif action == "delete":
        # python3 calendar_provider.py delete 2026-09-29 ev_1
        if len(sys.argv) >= 4:
            date_str = sys.argv[2]
            ev_id = sys.argv[3]

            events = load_events()
            if date_str in events:
                events[date_str] = [e for e in events[date_str] if e.get("id") != ev_id]
                if not events[date_str]:
                    del events[date_str]
                save_events(events)

            data = get_month_data(now.year, now.month)
            print(json.dumps(data))
    else:
        data = get_month_data(now.year, now.month)
        print(json.dumps(data))

if __name__ == "__main__":
    main()
