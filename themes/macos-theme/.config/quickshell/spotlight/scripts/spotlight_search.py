#!/usr/bin/env python3
"""
🌙 Lunita Spotlight Search Engine
High-performance query engine for Quickshell macOS Spotlight.
Searches applications, files, directories, calculations, system commands, and web shortcuts.
"""

import sys
import os
import glob
import json
import math
import re
import time
from datetime import datetime

HOME = os.path.expanduser("~")
HISTORY_FILE = os.path.join(HOME, ".config/lunita/spotlight-history.json")

ICON_MAP = {
    "safari": "assets/safari.svg",
    "zen": "assets/safari.svg",
    "firefox": "assets/safari.svg",
    "chrome": "assets/safari.svg",
    "chromium": "assets/safari.svg",
    "brave": "assets/safari.svg",
    "browser": "assets/safari.svg",
    "antigravity": "assets/code.svg",
    "cursor": "assets/code.svg",
    "code": "assets/code.svg",
    "vscodium": "assets/code.svg",
    "vscode": "assets/code.svg",
    "nvim": "assets/code.svg",
    "neovim": "assets/code.svg",
    "kitty": "assets/terminal.svg",
    "alacritty": "assets/terminal.svg",
    "terminal": "assets/terminal.svg",
    "dolphin": "assets/finder.svg",
    "nautilus": "assets/finder.svg",
    "thunar": "assets/finder.svg",
    "finder": "assets/finder.svg",
    "files": "assets/finder.svg",
    "spotify": "assets/music.svg",
    "music": "assets/music.svg",
    "amberol": "assets/music.svg",
    "cider": "assets/music.svg",
    "discord": "assets/messages.svg",
    "vesktop": "assets/messages.svg",
    "telegram": "assets/messages.svg",
    "messages": "assets/messages.svg",
    "whatsapp": "assets/messages.svg",
    "photos": "assets/photos.svg",
    "gwenview": "assets/photos.svg",
    "loupe": "assets/photos.svg",
    "settings": "assets/settings.svg",
    "systemsettings": "assets/settings.svg",
    "pavucontrol": "assets/settings.svg",
    "mail": "assets/mail.svg",
    "thunderbird": "assets/mail.svg",
    "notes": "assets/notes.svg",
    "obsidian": "assets/notes.svg",
    "calendar": "assets/calendar.svg",
    "reminders": "assets/reminders.svg",
    "keychain": "assets/keychain.svg",
    "keepassxc": "assets/keychain.svg",
    "bitwarden": "assets/keychain.svg",
    "appstore": "assets/appstore.svg",
    "discover": "assets/appstore.svg",
    "pamac": "assets/appstore.svg",
}

def resolve_app_icon(icon_name, app_id, exec_cmd):
    key = f"{app_id} {exec_cmd} {icon_name}".lower()
    for pattern, icon_path in ICON_MAP.items():
        if pattern in key:
            return icon_path
    
    if not icon_name:
        return "image://icon/application-x-executable"
    if icon_name.startswith("/"):
        return f"file://{icon_name}" if os.path.exists(icon_name) else "image://icon/application-x-executable"
    for ext in ["", ".png", ".svg", ".xpm"]:
        p = f"/usr/share/pixmaps/{icon_name}{ext}"
        if os.path.exists(p):
            return f"file://{p}"
    return f"image://icon/{icon_name}"

def resolve_file_icon(file_path, is_dir=False):
    if is_dir:
        return "assets/folder.svg"
    ext = os.path.splitext(file_path)[1].lower()
    if ext in [".png", ".jpg", ".jpeg", ".svg", ".webp", ".gif", ".ico", ".bmp"]:
        return "assets/photos.svg"
    if ext in [".mp3", ".wav", ".flac", ".ogg", ".m4a", ".aac", ".opus"]:
        return "assets/music.svg"
    if ext in [".mp4", ".mkv", ".webm", ".mov", ".avi", ".flv"]:
        return "assets/appletv.svg"
    if ext in [".py", ".qml", ".js", ".ts", ".html", ".css", ".lua", ".c", ".cpp", ".rs", ".go", ".sh", ".json", ".yaml", ".yml", ".toml", ".conf"]:
        return "assets/code.svg"
    if ext in [".pdf", ".doc", ".docx", ".odt", ".txt", ".md", ".rtf", ".csv", ".xlsx"]:
        return "assets/document.svg"
    if ext in [".zip", ".tar", ".gz", ".xz", ".7z", ".bz2", ".rar"]:
        return "assets/document.svg"
    return "assets/document.svg"

def format_size(size_bytes):
    if size_bytes < 1024:
        return f"{size_bytes} B"
    elif size_bytes < 1024 * 1024:
        return f"{size_bytes / 1024:.1f} KB"
    elif size_bytes < 1024 * 1024 * 1024:
        return f"{size_bytes / (1024 * 1024):.1f} MB"
    else:
        return f"{size_bytes / (1024 * 1024 * 1024):.2f} GB"

def load_history():
    try:
        if os.path.exists(HISTORY_FILE):
            with open(HISTORY_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
    except Exception:
        pass
    return []

def get_installed_apps():
    paths = glob.glob("/usr/share/applications/*.desktop") + glob.glob(os.path.expanduser("~/.local/share/applications/*.desktop"))
    apps = []
    seen = set()
    ignored = {"kitty URL Launcher", "Xwayland", "Hardware Locality lstopo", "Print Settings", "Avahi SSH Server Browser", "Avahi VNC Server Browser", "xgpsspeed"}

    for p in paths:
        try:
            with open(p, "r", encoding="utf-8", errors="ignore") as f:
                lines = f.readlines()
            name, icon, exec_cmd, desc, generic_name, cats_str, keywords_str = "", "", "", "", "", "", ""
            nodisplay = False
            for l in lines:
                l = l.strip()
                if l.startswith("Name=") and not name: name = l[5:]
                elif l.startswith("Icon=") and not icon: icon = l[5:]
                elif l.startswith("Exec=") and not exec_cmd: exec_cmd = l[5:]
                elif l.startswith("Comment=") and not desc: desc = l[8:]
                elif l.startswith("GenericName=") and not generic_name: generic_name = l[12:]
                elif l.startswith("Categories=") and not cats_str: cats_str = l[11:]
                elif l.startswith("Keywords=") and not keywords_str: keywords_str = l[9:]
                elif l == "NoDisplay=true": nodisplay = True
            
            if nodisplay or not name or not exec_cmd or name in ignored:
                continue
            
            desktop_id = os.path.basename(p)
            if desktop_id in seen:
                continue
            seen.add(desktop_id)
            
            clean_exec = exec_cmd.split("%")[0].strip()
            resolved_icon = resolve_app_icon(icon, desktop_id, clean_exec)
            
            apps.append({
                "id": desktop_id,
                "name": name,
                "genericName": generic_name,
                "description": desc or generic_name or "Application",
                "executable": clean_exec,
                "icon": resolved_icon,
                "desktopPath": p,
                "categories": cats_str,
                "keywords": keywords_str,
                "searchBlob": f"{name} {generic_name} {clean_exec} {desc} {keywords_str} {desktop_id}".lower()
            })
        except Exception:
            continue
    return apps

# ── Safe Math Evaluation ──
MATH_CONSTANTS = {
    "pi": math.pi,
    "e": math.e,
    "tau": math.tau if hasattr(math, "tau") else math.pi * 2,
    "inf": math.inf,
}

SAFE_MATH_FUNCS = {
    "sqrt": math.sqrt,
    "sin": math.sin,
    "cos": math.cos,
    "tan": math.tan,
    "asin": math.asin,
    "acos": math.acos,
    "atan": math.atan,
    "log": math.log,
    "log10": math.log10,
    "log2": math.log2,
    "exp": math.exp,
    "ceil": math.ceil,
    "floor": math.floor,
    "factorial": math.factorial,
    "radians": math.radians,
    "degrees": math.degrees,
    "abs": abs,
    "round": round,
    "pow": pow,
    "min": min,
    "max": max,
}

def evaluate_math(query):
    raw = query.strip()
    pct_match = re.match(r"^(\d+(?:\.\d+)?)\s*%\s*(?:of|de)\s*(\d+(?:\.\d+)?)$", raw, re.IGNORECASE)
    if pct_match:
        pct = float(pct_match.group(1))
        val = float(pct_match.group(2))
        res = (pct / 100.0) * val
        return {
            "title": f"= {res:g}",
            "expression": f"{pct}% of {val:g}",
            "resultStr": f"{res:g}"
        }

    expr = raw.replace("^", "**").replace("×", "*").replace("÷", "/")
    allowed_pattern = r"^[0-9\.\+\-\*\/\(\)\s\%\,\_a-zA-Z]+$"
    if not re.match(allowed_pattern, expr):
        return None
    
    has_operator = any(op in expr for op in ["+", "-", "*", "/", "%", "**"])
    has_func = any(f in expr for f in SAFE_MATH_FUNCS.keys())
    is_hex_bin = bool(re.match(r"^(0x[0-9a-fA-F]+|0b[01]+|0o[0-7]+)$", expr.strip()))
    
    if not (has_operator or has_func or is_hex_bin):
        return None

    try:
        scope = {**MATH_CONSTANTS, **SAFE_MATH_FUNCS}
        result = eval(expr, {"__builtins__": None}, scope)
        if isinstance(result, (int, float, complex)):
            if isinstance(result, float) and (math.isinf(result) or math.isnan(result)):
                return None
            res_str = f"{result:.10g}" if isinstance(result, float) else str(result)
            return {
                "title": f"= {res_str}",
                "expression": raw,
                "resultStr": res_str
            }
    except Exception:
        pass
    return None

# ── System Commands List ──
SYSTEM_COMMANDS = [
    {
        "title": "Lock Screen",
        "description": "Lock computer immediately using Hyprlock",
        "keywords": ["lock", "bloquear", "pantalla", "bloqueo", "sleep", "screen lock"],
        "icon": "assets/keychain.svg",
        "action": "$HOME/.config/hypr/scripts/smart_lock.sh classic || hyprlock",
        "kind": "Security"
    },
    {
        "title": "Take Screenshot",
        "description": "Capture region of the screen",
        "keywords": ["screenshot", "captura", "pantallazo", "grabar", "snip", "print"],
        "icon": "assets/photos.svg",
        "action": "$HOME/.config/hypr/scripts/screenshot.sh area",
        "kind": "Utility"
    },
    {
        "title": "Empty Trash",
        "description": "Permanently erase all deleted items in Trash",
        "keywords": ["trash", "papelera", "empty", "vaciar", "borrar", "clean"],
        "icon": "assets/trash-empty.svg",
        "action": "rm -rf $HOME/.local/share/Trash/* 2>/dev/null; notify-send 'Spotlight' 'Papelera vaciada'",
        "kind": "System"
    },
    {
        "title": "Restart System",
        "description": "Reboot the operating system",
        "keywords": ["restart", "reboot", "reiniciar", "sistema"],
        "icon": "assets/settings.svg",
        "action": "systemctl reboot",
        "kind": "Power"
    },
    {
        "title": "Shut Down",
        "description": "Power off the computer",
        "keywords": ["shutdown", "poweroff", "apagar", "apagar equipo"],
        "icon": "assets/settings.svg",
        "action": "systemctl poweroff",
        "kind": "Power"
    },
    {
        "title": "Suspend System",
        "description": "Put computer into low power suspend mode",
        "keywords": ["suspend", "sleep", "suspender", "hibernar", "reposo"],
        "icon": "assets/moon.svg",
        "action": "systemctl suspend",
        "kind": "Power"
    },
    {
        "title": "Log Out",
        "description": "Exit active Hyprland graphical session",
        "keywords": ["logout", "exit", "salir", "cerrar sesion", "desconectar"],
        "icon": "assets/keychain.svg",
        "action": "hyprctl dispatch exit",
        "kind": "Session"
    },
    {
        "title": "Audio & Sound Settings",
        "description": "Open volume and audio mixer controls",
        "keywords": ["sound", "audio", "volumen", "pavucontrol", "altavoces", "auriculares"],
        "icon": "assets/music.svg",
        "action": "pavucontrol",
        "kind": "Settings"
    }
]

# ── File Search Directories ──
SEARCH_DIRS = [
    os.path.join(HOME, "Desktop"),
    os.path.join(HOME, "Documents"),
    os.path.join(HOME, "Downloads"),
    os.path.join(HOME, "Pictures"),
    os.path.join(HOME, "Music"),
    os.path.join(HOME, "Videos"),
    "/mnt/Desarrollo",
    HOME
]

IGNORED_DIR_NAMES = {
    ".git", ".cache", ".local", "node_modules", "venv", ".venv", "__pycache__",
    "build", "dist", "target", ".cargo", ".rustup", ".npm", ".mozilla", ".gemini",
    ".android", ".var", "proc", "sys", "dev", "Trash", ".Trash", ".Trash-1000",
    "CMakeFiles", ".gradle", ".idea", ".vscode"
}

def search_files(query, max_results=8):
    q = query.lower()
    terms = q.split()
    results = []
    
    if query.startswith("/") or query.startswith("~"):
        target_path = os.path.expanduser(query)
        if os.path.exists(target_path):
            is_dir = os.path.isdir(target_path)
            stat = os.stat(target_path)
            results.append({
                "path": target_path,
                "name": os.path.basename(target_path) or target_path,
                "is_dir": is_dir,
                "size": format_size(stat.st_size) if not is_dir else "Folder",
                "mtime": datetime.fromtimestamp(stat.st_mtime).strftime("%b %d, %Y %H:%M"),
                "icon": resolve_file_icon(target_path, is_dir)
            })

    for base_dir in SEARCH_DIRS:
        if not os.path.exists(base_dir):
            continue
        try:
            max_depth = 1 if base_dir == HOME else 3
            _scan_dir(base_dir, terms, results, max_results, max_depth, current_depth=0)
            if len(results) >= max_results:
                break
        except Exception:
            continue

    return results[:max_results]

def _scan_dir(current_dir, terms, results, max_results, max_depth, current_depth):
    if current_depth > max_depth or len(results) >= max_results:
        return
    try:
        with os.scandir(current_dir) as it:
            for entry in it:
                if len(results) >= max_results:
                    break
                name = entry.name
                if name.startswith(".") and current_depth > 0:
                    continue
                if name in IGNORED_DIR_NAMES or name.startswith(".Trash"):
                    continue
                
                name_lower = name.lower()
                if all(t in name_lower for t in terms):
                    try:
                        stat = entry.stat(follow_symlinks=False)
                        is_dir = entry.is_dir(follow_symlinks=False)
                        results.append({
                            "path": entry.path,
                            "name": name,
                            "is_dir": is_dir,
                            "size": format_size(stat.st_size) if not is_dir else "Folder",
                            "mtime": datetime.fromtimestamp(stat.st_mtime).strftime("%b %d, %Y %H:%M"),
                            "icon": resolve_file_icon(entry.path, is_dir)
                        })
                    except Exception:
                        pass
                
                if entry.is_dir(follow_symlinks=False) and current_depth < max_depth:
                    _scan_dir(entry.path, terms, results, max_results, max_depth, current_depth + 1)
    except Exception:
        pass

def perform_search(query):
    query = query.strip()
    history = load_history()
    flat_items = []
    
    # ── EMPTY QUERY: Suggested Apps & Quick Actions ──
    if not query:
        apps = get_installed_apps()
        curated = ["zen", "firefox", "antigravity", "code", "kitty", "dolphin", "spotify", "discord"]
        suggested_apps = []
        for c in curated:
            for a in apps:
                if c in (a["id"] + " " + a["executable"]).lower() and a not in suggested_apps:
                    suggested_apps.append(a)
                    break
        
        for a in suggested_apps[:6]:
            flat_items.append({
                "id": f"app-{a['id']}",
                "title": a["name"],
                "subtitle": a["description"],
                "category": "SUGGESTIONS",
                "icon": a["icon"],
                "type": "app",
                "action": f"gtk-launch {a['id']} 2>/dev/null || {a['executable']} &",
                "revealAction": f"dolphin --select {a['desktopPath']}",
                "metadata": {
                    "kind": "Application",
                    "path": a["desktopPath"],
                    "executable": a["executable"],
                    "description": a["description"],
                    "genericName": a["genericName"]
                }
            })
            
        for cmd in SYSTEM_COMMANDS[:3]:
            flat_items.append({
                "id": f"sys-{cmd['title']}",
                "title": cmd["title"],
                "subtitle": cmd["description"],
                "category": "QUICK ACTIONS",
                "icon": cmd["icon"],
                "type": "command",
                "action": cmd["action"],
                "revealAction": "",
                "metadata": {
                    "kind": cmd["kind"],
                    "command": cmd["action"],
                    "description": cmd["description"]
                }
            })

        return json.dumps({"query": "", "results": flat_items, "totalCount": len(flat_items)})

    q_lower = query.lower()

    # ── 1. Terminal Command Mode ('>') ──
    if query.startswith(">"):
        cmd_str = query[1:].strip()
        if cmd_str:
            flat_items.append({
                "id": "terminal-exec",
                "title": f"Run '{cmd_str}'",
                "subtitle": "Execute in Kitty Terminal",
                "category": "TERMINAL COMMAND",
                "icon": "assets/command.svg",
                "type": "terminal",
                "action": f"kitty -e bash -c '{cmd_str}; exec bash'",
                "revealAction": "",
                "metadata": {
                    "kind": "Shell Command",
                    "command": cmd_str,
                    "description": f"Executes '{cmd_str}' in Kitty interactive shell."
                }
            })
            return json.dumps({"query": query, "results": flat_items, "totalCount": len(flat_items)})

    # ── 2. Calculator & Unit Evaluation ──
    calc_res = evaluate_math(query)
    if calc_res:
        flat_items.append({
            "id": "calc-result",
            "title": calc_res["title"],
            "subtitle": calc_res["expression"],
            "category": "CALCULATOR",
            "icon": "assets/calculator.svg",
            "type": "calc",
            "action": f"wl-copy '{calc_res['resultStr']}' 2>/dev/null || xclip -selection clipboard <<< '{calc_res['resultStr']}'; notify-send 'Spotlight' 'Resultado copiado: {calc_res['resultStr']}'",
            "revealAction": "",
            "metadata": {
                "kind": "Calculation",
                "result": calc_res["resultStr"],
                "expression": calc_res["expression"],
                "description": "Press Enter to copy result to clipboard."
            }
        })

    # ── 3. Application Search ──
    apps = get_installed_apps()
    scored_apps = []
    
    for a in apps:
        score = 0
        name_lower = a["name"].lower()
        id_lower = a["id"].lower()
        exec_lower = a["executable"].lower()
        blob = a["searchBlob"]
        
        if name_lower == q_lower:
            score = 100
        elif name_lower.startswith(q_lower):
            score = 90
        elif q_lower in name_lower:
            score = 80
        elif id_lower.startswith(q_lower) or exec_lower.startswith(q_lower):
            score = 70
        elif q_lower in blob:
            score = 50
        
        if a["id"] in history:
            score += 25
            
        if score > 0:
            scored_apps.append((score, a))
            
    scored_apps.sort(key=lambda x: x[0], reverse=True)
    
    has_top_hit = False
    for score, a in scored_apps[:8]:
        cat_name = "APPLICATIONS"
        if not has_top_hit and score >= 85 and len(flat_items) == 0:
            cat_name = "TOP HIT"
            has_top_hit = True
            
        flat_items.append({
            "id": f"app-{a['id']}",
            "title": a["name"],
            "subtitle": a["description"],
            "category": cat_name,
            "icon": a["icon"],
            "type": "app",
            "action": f"gtk-launch {a['id']} 2>/dev/null || {a['executable']} &",
            "revealAction": f"dolphin --select {a['desktopPath']}",
            "metadata": {
                "kind": "Application",
                "path": a["desktopPath"],
                "executable": a["executable"],
                "description": a["description"],
                "genericName": a["genericName"]
            }
        })

    # ── 4. System Commands ──
    matched_sys = []
    for cmd in SYSTEM_COMMANDS:
        if any(q_lower in kw for kw in cmd["keywords"]) or q_lower in cmd["title"].lower():
            matched_sys.append(cmd)
            
    for cmd in matched_sys[:3]:
        flat_items.append({
            "id": f"sys-{cmd['title']}",
            "title": cmd["title"],
            "subtitle": cmd["description"],
            "category": "SYSTEM COMMANDS",
            "icon": cmd["icon"],
            "type": "command",
            "action": cmd["action"],
            "revealAction": "",
            "metadata": {
                "kind": cmd["kind"],
                "command": cmd["action"],
                "description": cmd["description"]
            }
        })

    # ── 5. Files & Folders Search ──
    files = search_files(query, max_results=8)
    for f in files:
        is_folder = f["is_dir"]
        cat_name = "FOLDERS" if is_folder else "DOCUMENTS & FILES"
        action = f"xdg-open '{f['path']}' &"
        reveal = f"dolphin --select '{f['path']}'" if not is_folder else f"dolphin '{f['path']}'"
        
        flat_items.append({
            "id": f"file-{f['path']}",
            "title": f["name"],
            "subtitle": f["path"].replace(HOME, "~"),
            "category": cat_name,
            "icon": f["icon"],
            "type": "folder" if is_folder else "file",
            "action": action,
            "revealAction": reveal,
            "metadata": {
                "kind": "Folder" if is_folder else "Document / File",
                "path": f["path"],
                "size": f["size"],
                "modified": f["mtime"]
            }
        })

    # ── 6. Web Search & URL Direct Jump ──
    is_url = bool(re.match(r"^(https?:\/\/|[a-zA-Z0-9-]+\.[a-zA-Z]{2,})(\/.*)?$", query))
    if is_url:
        url = query if query.startswith("http") else f"https://{query}"
        flat_items.append({
            "id": "web-url",
            "title": f"Open '{query}'",
            "subtitle": f"Visit {url}",
            "category": "WEB SHORTCUT",
            "icon": "assets/safari.svg",
            "type": "web",
            "action": f"xdg-open '{url}' &",
            "revealAction": "",
            "metadata": {
                "kind": "Website Link",
                "url": url,
                "description": f"Opens {url} in your default browser."
            }
        })
    else:
        google_url = f"https://www.google.com/search?q={query.replace(' ', '+')}"
        flat_items.append({
            "id": "web-search",
            "title": f"Search Google for \"{query}\"",
            "subtitle": "Search the web in default browser",
            "category": "WEB SEARCH",
            "icon": "assets/globe.svg",
            "type": "web",
            "action": f"xdg-open '{google_url}' &",
            "revealAction": "",
            "metadata": {
                "kind": "Web Search",
                "url": google_url,
                "description": f"Performs a web search for '{query}'"
            }
        })

    return json.dumps({
        "query": query,
        "results": flat_items,
        "totalCount": len(flat_items)
    })

def main():
    if len(sys.argv) > 1:
        query = " ".join(sys.argv[1:])
        print(perform_search(query))
    else:
        for line in sys.stdin:
            line = line.strip()
            print(perform_search(line), flush=True)

if __name__ == "__main__":
    main()
