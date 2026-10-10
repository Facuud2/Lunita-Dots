#!/usr/bin/env python3
"""Lista las apps instaladas leyendo los .desktop y resolviendo sus iconos, para el lanzador."""
import configparser
import json
import os
import sys

search_dirs = [
    os.path.expanduser("~/.local/share/icons"),
    os.path.expanduser("~/.icons"),
    "/usr/share/icons",
    "/usr/share/pixmaps"
]
themes = ["BeautyLine", "Tela-circle-dark", "Papirus", "breeze", "Adwaita", "hicolor"]
exts = [".svg", ".png", ".xpm"]

def build_icon_cache():
    cache = {}
    for base in search_dirs:
        if not os.path.exists(base):
            continue
        if base == "/usr/share/pixmaps":
            for f in os.listdir(base):
                n, ext = os.path.splitext(f)
                if ext.lower() in exts and n not in cache:
                    cache[n] = os.path.join(base, f)
            continue
        for t in themes:
            td = os.path.join(base, t)
            if not os.path.exists(td):
                continue
            for root, dirs, files in os.walk(td):
                for f in files:
                    n, ext = os.path.splitext(f)
                    if ext.lower() in exts:
                        full = os.path.join(root, f)
                        if n not in cache:
                            cache[n] = full
                        elif "16x16" in cache[n] or "22x22" in cache[n]:
                            if any(k in full for k in ["scalable", "48x48", "64x64", "128x128", "apps"]):
                                cache[n] = full
    return cache

icon_cache = build_icon_cache()

def resolve_icon(icon_name):
    if not icon_name:
        return ""
    if icon_name.startswith("/") or icon_name.startswith("file://"):
        return icon_name if icon_name.startswith("file://") else "file://" + icon_name
    if icon_name in icon_cache:
        return "file://" + icon_cache[icon_name]
    return ""

def app_dirs():
    dirs = [os.path.expanduser("~/.local/share/applications")]
    xdg = os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share")
    dirs += [os.path.join(d, "applications") for d in xdg.split(":") if d]
    return dirs

def scan():
    seen = {}
    for d in app_dirs():
        if not os.path.isdir(d):
            continue
        for root, _dirs, files in os.walk(d):
            for f in files:
                if not f.endswith(".desktop") or f in seen:
                    continue
                cfg = configparser.ConfigParser(interpolation=None, strict=False)
                try:
                    cfg.read(os.path.join(root, f), encoding="utf-8")
                except Exception:
                    continue
                if "Desktop Entry" not in cfg:
                    continue
                e = cfg["Desktop Entry"]
                if e.get("Type", "Application") != "Application":
                    continue
                if e.get("NoDisplay", "false").lower() == "true":
                    continue
                if e.get("Hidden", "false").lower() == "true":
                    continue
                name = e.get("Name", "")
                if not name:
                    continue
                icon_raw = e.get("Icon", "")
                seen[f] = {
                    "name": name,
                    "generic": e.get("GenericName", ""),
                    "icon": resolve_icon(icon_raw),
                    "icon_raw": icon_raw,
                    "path": os.path.join(root, f),
                }
    res = sorted(seen.values(), key=lambda a: a["name"].lower())
    
    # También persistimos en cache json para carga atómica instantánea
    try:
        cache_file = os.path.expanduser("~/.cache/quickshell_launcher_apps.json")
        with open(cache_file, "w", encoding="utf-8") as fp:
            json.dump(res, fp, ensure_ascii=False)
    except Exception:
        pass

    return res

if __name__ == "__main__":
    apps = scan()
    # Emite una sola línea compacta
    sys.stdout.write(json.dumps(apps, ensure_ascii=False) + "\n")
    sys.stdout.flush()
