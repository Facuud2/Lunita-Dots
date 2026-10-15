#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Lunita-Dots — Modern Win11 Launcher App Scanner
Detects installed .desktop applications (including System, User, and Flatpak apps)
and resolves high-resolution icons from Freedesktop icon themes and Flatpak exports.
"""

import os
import glob
import json
import re

def get_all_data_dirs():
    """Collect all XDG and standard data directories including Flatpak exports."""
    dirs = []
    # 1. Environment variable XDG_DATA_DIRS
    env_dirs = [p.strip() for p in os.environ.get("XDG_DATA_DIRS", "").split(":") if p.strip()]
    for d in env_dirs:
        if d not in dirs and os.path.exists(d):
            dirs.append(d)

    # 2. Standard user and system application directories (including Flatpak)
    standard = [
        os.path.expanduser("~/.local/share/flatpak/exports/share"),
        "/var/lib/flatpak/exports/share",
        os.path.expanduser("~/.local/share"),
        "/usr/local/share",
        "/usr/share"
    ]
    for d in standard:
        if d not in dirs and os.path.exists(d):
            dirs.append(d)

    return dirs

def get_search_icon_dirs(data_dirs):
    """Build list of icon theme search directories."""
    dirs = [
        os.path.expanduser("~/.local/share/icons/WhiteSur"),
        os.path.expanduser("~/.local/share/icons/WhiteSur-dark"),
        os.path.expanduser("~/.local/share/icons/Papirus-Dark"),
        os.path.expanduser("~/.local/share/icons/Papirus"),
        os.path.expanduser("~/.local/share/icons/hicolor"),
        os.path.expanduser("~/.local/share/flatpak/exports/share/icons"),
        "/var/lib/flatpak/exports/share/icons",
        "/usr/share/icons/hicolor",
        "/usr/share/icons/breeze",
        "/usr/share/icons/breeze-dark",
        "/usr/share/icons",
        "/usr/share/pixmaps",
        "/mnt/Desarrollo/Lunita-Dots/core"
    ]

    for d in data_dirs:
        ic = os.path.join(d, "icons")
        if ic not in dirs and os.path.exists(ic):
            dirs.append(ic)
        px = os.path.join(d, "pixmaps")
        if px not in dirs and os.path.exists(px):
            dirs.append(px)

    return dirs

IGNORED_DESKTOPS = {
    "kitty URL Launcher", "Xwayland", "Hardware Locality lstopo",
    "Print Settings", "Avahi SSH Server Browser", "Avahi VNC Server Browser",
    "xgpsspeed", "View file", "Avahi Zeroconf Browser", "Uninstall MAKO Renderer"
}

FRIENDLY_NAMES = {
    "zen.desktop": "Zen Browser",
    "com.microsoft.VSCode.desktop": "VS Code",
    "antigravity.desktop": "Antigravity",
    "kitty.desktop": "Kitty",
    "org.kde.dolphin.desktop": "Dolphin",
    "vesktop.desktop": "Vesktop",
    "org.prismlauncher.PrismLauncher.desktop": "Prism Launcher",
    "org.vinegarhq.Sober.desktop": "Sober",
    "com.ysuraj.Tokri.desktop": "Tokri",
    "firefox.desktop": "Firefox",
    "org.kde.gwenview.desktop": "Gwenview",
    "mpv.desktop": "mpv",
    "nvim.desktop": "Neovim",
    "org.pulseaudio.pavucontrol.desktop": "Audio",
    "nwg-displays.desktop": "Pantallas",
    "blueman-manager.desktop": "Bluetooth",
    "ai.elementlabs.lmstudio.desktop": "LM-Studio",
    "timeshift-gtk.desktop": "Timeshift",
    "lunita-widgets-manager.desktop": "Widgets",
    "lunita-theme-selector.desktop": "Temas"
}

def score_icon_path(p):
    score = 0
    pl = p.lower()
    if "apps" in pl:
        score += 50
    if "scalable" in pl:
        score += 40
    elif "256x256" in pl or "512x512" in pl:
        score += 35
    elif "128x128" in pl:
        score += 30
    elif "64x64" in pl or "48x48" in pl:
        score += 25
    elif "32x32" in pl:
        score += 15
    elif "16x16" in pl or "/16/" in pl:
        score += 0

    if p.endswith(".svg"):
        score += 10
    elif p.endswith(".png"):
        score += 5

    if "whitesur" in pl:
        score += 20
    elif "papirus" in pl:
        score += 15
    elif "flatpak" in pl:
        score += 18
    return score

def build_icon_index(search_dirs):
    index = {}
    scores = {}

    for d in search_dirs:
        if not os.path.exists(d):
            continue
        try:
            for root, dirs, files in os.walk(d):
                for f in files:
                    if f.endswith((".svg", ".png", ".xpm")):
                        base = os.path.splitext(f)[0]
                        p = os.path.join(root, f)
                        sc = score_icon_path(p)

                        # Prefer highest resolution icon
                        if base not in index or sc > scores.get(base, 0):
                            index[base] = "file://" + p
                            scores[base] = sc
                        if f not in index or sc > scores.get(f, 0):
                            index[f] = "file://" + p
                            scores[f] = sc
        except Exception:
            pass

    return index

def find_icon(icon_name, icon_index):
    if not icon_name:
        return "image://icon/application-x-executable"

    # Absolute file path
    if icon_name.startswith("/"):
        if os.path.exists(icon_name):
            return "file://" + icon_name
        icon_name = os.path.splitext(os.path.basename(icon_name))[0]

    # Look up in index
    if icon_name in icon_index:
        return icon_index[icon_name]

    base = os.path.splitext(icon_name)[0]
    if base in icon_index:
        return icon_index[base]

    lower = icon_name.lower()
    if lower in icon_index:
        return icon_index[lower]

    return "image://icon/" + icon_name

def categorize(cats_str, name, exec_cmd, desc, desktop_id):
    c = " ".join([cats_str, name, exec_cmd, desc, desktop_id]).lower()
    if re.search(r"\b(development|ide|debugger|programming|code|terminal|editor|texteditor|neovim|nvim|vim|gvim|kitty|cmake|vscode|vscodium|antigravity)\b", c):
        return "Desarrollo & Terminal"
    if re.search(r"\b(audiovideo|audio|music|player|multimedia|game|games|gaming|roblox|sober|vinegar|entertainment|media|mpv|vlc|prism|minecraft|bedrock|gwenview|graphics|video|songrec|goverlay|image|photo)\b", c):
        return "Medios & Juegos"
    if re.search(r"\b(webbrowser|browser|network|internet|mail|email|chat|im|messaging|discord|vesktop|zen|firefox|chrome|vpn|proton|telegram|whatsapp|signal)\b", c):
        return "Internet & Red"
    return "Sistema & Herramientas"

def main():
    data_dirs = get_all_data_dirs()
    search_dirs = get_search_icon_dirs(data_dirs)
    icon_index = build_icon_index(search_dirs)

    desktop_paths = []
    seen_paths = set()
    for d in data_dirs:
        app_dir = os.path.join(d, "applications")
        if os.path.exists(app_dir):
            for pattern in [os.path.join(app_dir, "*.desktop"), os.path.join(app_dir, "**", "*.desktop")]:
                for p in glob.glob(pattern, recursive=True):
                    if p not in seen_paths:
                        seen_paths.add(p)
                        desktop_paths.append(p)

    apps = []
    seen = set()

    for p in desktop_paths:
        name, icon, exec_cmd, desc, cats_str = "", "", "", "", ""
        nodisplay = False
        try:
            with open(p, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("Name=") and not name:
                        name = line[5:].strip()
                    elif line.startswith("Icon=") and not icon:
                        icon = line[5:].strip()
                    elif line.startswith("Exec=") and not exec_cmd:
                        exec_cmd = line[5:].strip()
                    elif line.startswith("Comment=") and not desc:
                        desc = line[8:].strip()
                    elif line.startswith("Categories=") and not cats_str:
                        cats_str = line[11:].strip()
                    elif line == "NoDisplay=true":
                        nodisplay = True
        except Exception:
            continue

        if nodisplay or not name or not exec_cmd or name in IGNORED_DESKTOPS:
            continue

        desktop_id = os.path.basename(p)
        if desktop_id in seen:
            continue
        seen.add(desktop_id)

        # Clean Exec parameter (strip Flatpak @@ URL forwarders and % arguments)
        clean_exec = re.sub(r'@@.*?@@', '', exec_cmd)
        clean_exec = re.sub(r'%[a-zA-Z0-9]', '', clean_exec)
        clean_exec = re.sub(r'\s+--\s*$', '', clean_exec).strip()

        cat = categorize(cats_str, name, clean_exec, desc, desktop_id)
        icon_res = find_icon(icon, icon_index)
        disp_name = FRIENDLY_NAMES.get(desktop_id, name)

        apps.append({
            "id": desktop_id,
            "name": name,
            "displayName": disp_name,
            "description": desc,
            "executable": clean_exec,
            "iconName": icon,
            "resolvedIcon": icon_res,
            "category": cat,
            "desktopPath": p
        })

    apps.sort(key=lambda x: x["displayName"].lower())
    print(json.dumps(apps))

if __name__ == "__main__":
    main()
