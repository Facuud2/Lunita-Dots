#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — Weather Provider for Quickshell Clock & Weather Widget
# Fetches local weather from wttr.in with 15-minute caching, custom location & offline fallback
# ==============================================================================

import os
import sys
import json
import time
import datetime
import urllib.request
import urllib.parse
import urllib.error

CACHE_FILE = "/tmp/lunita_weather_cache.json"
LOCATION_FILE = os.path.expanduser("~/.config/lunita/weather_location")
CACHE_TTL = 900  # 15 minutos en segundos

# Mapeo de códigos de wttr.in (WWO codes) a iconos Nerd Font y descripciones breves en español
WEATHER_CODES = {
    "113": ("󰖙", "󰖔", "Despejado"),               # Sunny / Clear
    "116": ("󰖕", "󰼱", "Parcialmente nublado"),   # Partly Cloudy
    "119": ("󰖐", "󰖐", "Nublado"),               # Cloudy
    "122": ("󰖐", "󰖐", "Cubierto"),              # Overcast
    "143": ("󰖒", "󰖒", "Neblina"),               # Mist
    "176": ("󰖖", "󰖖", "Llovizna dispersa"),     # Patchy rain nearby
    "179": ("󰼳", "󰼳", "Aguanieve dispersa"),    # Patchy snow nearby
    "182": ("󰼳", "󰼳", "Aguanieve"),             # Patchy sleet
    "185": ("󰼳", "󰼳", "Llovizna helada"),       # Patchy freezing drizzle
    "200": ("󰖗", "󰖗", "Tormenta eléctrica"),    # Thundery outbreaks
    "227": ("󰼳", "󰼳", "Viento y nieve"),        # Blowing snow
    "230": ("󰼳", "󰼳", "Ventisca"),              # Blizzard
    "248": ("󰖒", "󰖒", "Niebla"),                # Fog
    "260": ("󰖒", "󰖒", "Niebla helada"),         # Freezing fog
    "263": ("󰖖", "󰖖", "Llovizna leve"),         # Patchy light drizzle
    "266": ("󰖖", "󰖖", "Lluvia leve"),           # Light drizzle
    "281": ("󰼳", "󰼳", "Llovizna helada"),       # Freezing drizzle
    "284": ("󰼳", "󰼳", "Llovizna helada fuerte"),# Heavy freezing drizzle
    "293": ("󰖖", "󰖖", "Lluvia ligera dispersa"),# Patchy light rain
    "296": ("󰖖", "󰖖", "Lluvia ligera"),         # Light rain
    "299": ("󰖖", "󰖖", "Chaparrones"),          # Moderate rain at times
    "302": ("󰖖", "󰖖", "Lluvia moderada"),       # Moderate rain
    "305": ("󰖖", "󰖖", "Lluvia fuerte"),         # Heavy rain at times
    "308": ("󰖖", "󰖖", "Lluvia torrencial"),     # Heavy rain
    "311": ("󰼳", "󰼳", "Lluvia helada"),         # Light freezing rain
    "314": ("󰼳", "󰼳", "Lluvia helada fuerte"),  # Moderate/heavy freezing rain
    "353": ("󰖖", "󰖖", "Chubasco leve"),         # Light rain shower
    "356": ("󰖖", "󰖖", "Chubasco fuerte"),       # Moderate/heavy rain shower
    "386": ("󰖗", "󰖗", "Tormenta con lluvia"),    # Patchy light rain with thunder
    "389": ("󰖗", "󰖗", "Tormenta severa"),       # Moderate/heavy rain with thunder
    "392": ("󰖗", "󰖗", "Tormenta de nieve"),     # Patchy light snow with thunder
    "395": ("󰖗", "󰖗", "Tormenta de nieve fuerte"),# Moderate/heavy snow with thunder
}

def get_icon(code, is_night=False):
    info = WEATHER_CODES.get(str(code))
    if not info:
        return "󰖔" if is_night else "󰖙"
    return info[1] if is_night else info[0]

def get_desc(code, raw_desc=""):
    info = WEATHER_CODES.get(str(code))
    if info:
        return info[2]
    return raw_desc or "Templado"

def get_condition_type(code):
    c = str(code)
    if c in ["113"]: return "sunny"
    if c in ["116"]: return "partly_cloudy"
    if c in ["119", "122"]: return "cloudy"
    if c in ["176", "263", "266", "293", "296", "299", "302", "305", "308", "353", "356"]: return "rain"
    if c in ["200", "386", "389", "392", "395"]: return "thunder"
    if c in ["179", "182", "185", "227", "230", "311", "314"]: return "snow"
    if c in ["143", "248", "260"]: return "fog"
    return "cloudy"

def format_ios_hour(hour):
    h12 = hour % 12
    h_num = 12 if h12 == 0 else h12
    suffix = "a.m." if hour < 12 else "p.m."
    return f"{h_num} {suffix}"

def get_saved_location():
    if os.path.exists(LOCATION_FILE):
        try:
            with open(LOCATION_FILE, "r") as f:
                loc = f.read().strip()
                if loc and loc.lower() != "auto":
                    return loc
        except Exception:
            pass
    return None

def fetch_from_api(city=None):
    if city:
        query = urllib.parse.quote(city)
        url = f"https://wttr.in/{query}?format=j1"
    else:
        url = "https://wttr.in/?format=j1"
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "curl/7.88.1"}
    )
    with urllib.request.urlopen(req, timeout=5) as resp:
        content = resp.read().decode("utf-8")
        return json.loads(content)

def load_cache():
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r") as f:
                data = json.load(f)
                if time.time() - data.get("timestamp", 0) < CACHE_TTL:
                    return data.get("payload")
        except Exception:
            pass
    return None

def save_cache(payload):
    try:
        with open(CACHE_FILE, "w") as f:
            json.dump({"timestamp": time.time(), "payload": payload}, f)
    except Exception:
        pass

def parse_weather_data(raw, custom_city=None):
    try:
        curr = raw["current_condition"][0]
        temp_c = curr.get("temp_C", "20")
        humidity = curr.get("humidity", "50") + "%"
        wind_kmph = curr.get("windspeedKmph", "10") + " km/h"
        code = curr.get("weatherCode", "113")
        raw_desc = curr.get("weatherDesc", [{}])[0].get("value", "")

        now = datetime.datetime.now()
        is_night = (now.hour < 6 or now.hour >= 20)
        icon = get_icon(code, is_night)
        desc = get_desc(code, raw_desc)

        # Detectar ciudad si está disponible
        area = raw.get("nearest_area", [{}])[0]
        detected_city = area.get("areaName", [{}])[0].get("value", "")
        city_display = (custom_city if custom_city else detected_city).upper()

        # Extraer pronóstico de las próximas 6 horas (estilo iOS Weather)
        hourly_forecast = []
        weather_days = raw.get("weather", [])
        all_hourly = []
        for d_idx, day_obj in enumerate(weather_days[:2]):
            for h in day_obj.get("hourly", []):
                h_val = int(h.get("time", "0")) // 100
                all_hourly.append({
                    "day_offset": d_idx,
                    "hour": h_val,
                    "temp": h.get("tempC", temp_c),
                    "code": h.get("weatherCode", "113")
                })

        # Buscar las 6 siguientes horas relativas al momento actual
        cur_hour = now.hour
        for step in range(0, 6):
            target_hour = (cur_hour + step) % 24
            day_offset = (cur_hour + step) // 24

            best_match = None
            min_diff = 999
            for slot in all_hourly:
                if slot["day_offset"] == day_offset:
                    diff = abs(slot["hour"] - target_hour)
                    if diff < min_diff:
                        min_diff = diff
                        best_match = slot

            step_temp = (best_match["temp"] if best_match else temp_c) + "°"
            step_code = best_match["code"] if best_match else code
            step_is_night = (target_hour < 6 or target_hour >= 20)
            step_icon = get_icon(step_code, step_is_night)
            step_cond = get_condition_type(step_code)
            time_label = format_ios_hour(target_hour)

            hourly_forecast.append({
                "time": time_label,
                "hour": target_hour,
                "temp": step_temp,
                "icon": step_icon,
                "condition_type": step_cond
            })

        # Extraer pronóstico diario para hasta 5 días posteriores
        daily_forecast = []
        days_names_es = ["LUN", "MAR", "MIÉ", "JUE", "VIE", "SÁB", "DOM"]
        for d_idx, day_obj in enumerate(weather_days[:5]):
            d_date_str = day_obj.get("date", "")
            max_t = day_obj.get("maxtempC", temp_c) + "°"
            min_t = day_obj.get("mintempC", temp_c) + "°"
            hourlies = day_obj.get("hourly", [])
            mid_h = hourlies[len(hourlies)//2] if hourlies else {}
            d_code = mid_h.get("weatherCode", code)
            d_desc = get_desc(d_code, mid_h.get("weatherDesc", [{}])[0].get("value", desc) if mid_h.get("weatherDesc") else desc)
            d_icon = get_icon(d_code, False)
            d_cond = get_condition_type(d_code)

            if d_idx == 0:
                d_label = "Hoy"
            elif d_idx == 1:
                d_label = "Mañana"
            else:
                try:
                    dt = datetime.datetime.strptime(d_date_str, "%Y-%m-%d")
                    d_label = days_names_es[dt.weekday()]
                except Exception:
                    d_label = f"+{d_idx}d"

            daily_forecast.append({
                "day": d_label,
                "date": d_date_str,
                "max": max_t,
                "min": min_t,
                "icon": d_icon,
                "desc": d_desc,
                "condition_type": d_cond
            })

        today_max = daily_forecast[0]["max"] if daily_forecast else f"{int(temp_c)+3}°"
        today_min = daily_forecast[0]["min"] if daily_forecast else f"{max(0, int(temp_c)-4)}°"
        city_formatted = (custom_city if custom_city else detected_city).strip()
        if not city_formatted or city_formatted.upper() == "BUENOS AIRES":
            city_formatted = "Buenos Aires"
        else:
            city_formatted = city_formatted.title()

        return {
            "temp": f"{temp_c}°C",
            "temp_val": f"{temp_c}°",
            "temp_num": int(temp_c),
            "max": today_max,
            "min": today_min,
            "condition_type": get_condition_type(code),
            "icon": icon,
            "desc": desc,
            "humidity": humidity,
            "wind": wind_kmph,
            "city": city_display if city_display else "BUENOS AIRES",
            "city_name": city_formatted,
            "is_custom_location": bool(custom_city),
            "hourly": hourly_forecast,
            "daily": daily_forecast
        }
    except Exception:
        return None

def fallback_data(city_name="Buenos Aires"):
    now = datetime.datetime.now()
    hourly = []
    for step in range(0, 6):
        h = (now.hour + step) % 24
        night = (h < 6 or h >= 20)
        h_temp = 13 + (step if step < 4 else 5)
        hourly.append({
            "time": format_ios_hour(h),
            "hour": h,
            "temp": f"{h_temp}°",
            "icon": "󰖐" if step != 3 else "󰖕",
            "condition_type": "cloudy" if step != 3 else "partly_cloudy"
        })
    daily = [
        {"day": "Hoy", "date": now.strftime("%Y-%m-%d"), "max": "18°", "min": "11°", "icon": "󰖐", "desc": "Nublado", "condition_type": "cloudy"},
        {"day": "Mañana", "date": (now + datetime.timedelta(days=1)).strftime("%Y-%m-%d"), "max": "19°", "min": "12°", "icon": "󰖕", "desc": "Parcialmente nublado", "condition_type": "partly_cloudy"},
        {"day": "MAR", "date": (now + datetime.timedelta(days=2)).strftime("%Y-%m-%d"), "max": "21°", "min": "13°", "icon": "󰖙", "desc": "Despejado", "condition_type": "sunny"},
        {"day": "MIÉ", "date": (now + datetime.timedelta(days=3)).strftime("%Y-%m-%d"), "max": "20°", "min": "14°", "icon": "󰖖", "desc": "Lluvia ligera", "condition_type": "rain"},
        {"day": "JUE", "date": (now + datetime.timedelta(days=4)).strftime("%Y-%m-%d"), "max": "18°", "min": "12°", "icon": "󰖐", "desc": "Nublado", "condition_type": "cloudy"}
    ]
    return {
        "temp": "13°C",
        "temp_val": "13°",
        "temp_num": 13,
        "max": "18°",
        "min": "11°",
        "condition_type": "cloudy",
        "icon": "󰖐",
        "desc": "Nublado",
        "humidity": "72%",
        "wind": "14 km/h",
        "city": "BUENOS AIRES",
        "city_name": "Buenos Aires" if (not city_name or city_name.upper() == "BUENOS AIRES") else city_name.title(),
        "is_custom_location": False,
        "hourly": hourly,
        "daily": daily
    }

def main():
    target_city = None
    force_refresh = False

    # Manejar argumentos de línea de comandos
    if len(sys.argv) > 1:
        cmd = sys.argv[1].strip()
        if cmd == "set" and len(sys.argv) > 2:
            target_city = " ".join(sys.argv[2:]).strip()
            os.makedirs(os.path.dirname(LOCATION_FILE), exist_ok=True)
            with open(LOCATION_FILE, "w") as f:
                f.write(target_city)
            if os.path.exists(CACHE_FILE):
                try: os.remove(CACHE_FILE)
                except Exception: pass
            force_refresh = True
        elif cmd in ["clear", "auto"]:
            if os.path.exists(LOCATION_FILE):
                try: os.remove(LOCATION_FILE)
                except Exception: pass
            if os.path.exists(CACHE_FILE):
                try: os.remove(CACHE_FILE)
                except Exception: pass
            target_city = None
            force_refresh = True
        elif cmd in ["refresh", "force"]:
            if os.path.exists(CACHE_FILE):
                try: os.remove(CACHE_FILE)
                except Exception: pass
            force_refresh = True
            target_city = get_saved_location()
        else:
            target_city = cmd
            force_refresh = True
    else:
        target_city = get_saved_location()

    # 1. Probar desde caché si está vigente y no se forzó refresco
    if not force_refresh:
        cached = load_cache()
        if cached:
            print(json.dumps(cached))
            return

    # 2. Descargar datos frescos de la API
    try:
        raw = fetch_from_api(target_city)
        parsed = parse_weather_data(raw, target_city)
        if parsed:
            save_cache(parsed)
            print(json.dumps(parsed))
            return
    except Exception:
        pass

    # 3. Si falló la red pero hay caché en disco
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r") as f:
                d = json.load(f)
                if "payload" in d:
                    print(json.dumps(d["payload"]))
                    return
        except Exception:
            pass

    # 4. Fallback sintético elegante
    print(json.dumps(fallback_data(target_city or "BUENOS AIRES")))

if __name__ == "__main__":
    main()
