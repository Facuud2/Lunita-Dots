#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — macOS Calendar Widget Stream Provider
# ==============================================================================

import sys
import json
import time
import calendar
import datetime

MONTHS_ES = [
    "", "ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO",
    "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"
]

DAYS_ES = [
    "LUNES", "MARTES", "MIÉRCOLES", "JUEVES", "VIERNES", "SÁBADO", "DOMINGO"
]

WEEKDAY_INITIALS = ["D", "L", "M", "M", "J", "V", "S"]

def get_calendar_payload():
    now = datetime.datetime.now()
    year = now.year
    month = now.month
    today = now.day
    weekday_idx = now.weekday() # 0 = Monday, 6 = Sunday

    month_name = MONTHS_ES[month]
    weekday_name = DAYS_ES[weekday_idx]

    # Calendar starting on Sunday (firstweekday=6) matching macOS standard
    cal = calendar.Calendar(firstweekday=6)
    month_days = cal.monthdayscalendar(year, month)

    weeks = []
    for week in month_days:
        week_row = []
        for day_num in week:
            if day_num == 0:
                week_row.append({
                    "day": "",
                    "is_today": False,
                    "in_month": False
                })
            else:
                week_row.append({
                    "day": str(day_num),
                    "is_today": (day_num == today),
                    "in_month": True
                })
        weeks.append(week_row)

    return {
        "month_name": month_name,
        "year": str(year),
        "today": str(today),
        "weekday": weekday_name,
        "weekdays": WEEKDAY_INITIALS,
        "weeks": weeks
    }

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "get"

    if action == "get":
        print(json.dumps(get_calendar_payload()))
    elif action == "watch":
        last_day = None
        while True:
            payload = get_calendar_payload()
            print(json.dumps(payload), flush=True)
            # Sleep 30 seconds before re-checking
            time.sleep(30)

if __name__ == "__main__":
    main()
