#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — Photo Provider for Quickshell Widgets
# Recursively scans ~/Imagenes/* and manages smooth image progression
# ==============================================================================

import os
import sys
import json
import time

STATE_FILE = "/tmp/lunita_qs_photos_state.json"
VALID_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".jfif"}

SEARCH_DIRS = [
    os.path.expanduser("~/Imagenes"),
    os.path.expanduser("~/Imágenes"),
    os.path.expanduser("~/Pictures"),
    os.path.expanduser("~/Wallpapers"),
    os.path.expanduser("~/Downloads")
]

def get_all_images():
    images = []
    seen = set()
    for base in SEARCH_DIRS:
        if not os.path.exists(base):
            continue
        for root, _, files in os.walk(base):
            for f in sorted(files):
                ext = os.path.splitext(f)[1].lower()
                if ext in VALID_EXTENSIONS:
                    full = os.path.abspath(os.path.join(root, f))
                    if full not in seen:
                        seen.add(full)
                        folder = os.path.basename(root)
                        cat = "Recuerdos" if folder in ["Imagenes", "Imágenes", "Pictures", ""] else folder
                        title = os.path.splitext(f)[0].replace("_", " ").replace("-", " ")
                        if len(title) > 28:
                            title = title[:26] + "..."
                        images.append({
                            "path": full,
                            "title": title,
                            "subtitle": cat
                        })
    return images

def load_state():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return {"index": 0}

def save_state(s):
    try:
        with open(STATE_FILE, "w") as f:
            json.dump(s, f)
    except Exception:
        pass

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "get"
    images = get_all_images()
    
    if not images:
        print(json.dumps({
            "path": "",
            "title": "Sin Fotos",
            "subtitle": "Recuerdos",
            "index": 1,
            "total": 1,
            "direction": 1
        }))
        return

    state = load_state()
    cur_idx = state.get("index", 0)

    direction = 1
    if action == "delete":
        if cur_idx < len(images):
            target = images[cur_idx]["path"]
            try:
                import subprocess
                subprocess.run(["gio", "trash", target], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            except Exception:
                try:
                    os.remove(target)
                except Exception:
                    pass
        images = get_all_images()
        if not images:
            print(json.dumps({
                "path": "",
                "title": "Sin Fotos",
                "subtitle": "Recuerdos",
                "index": 1,
                "total": 1,
                "direction": 1
            }))
            return
        cur_idx = cur_idx % len(images)
        direction = 1
    elif action == "next":
        cur_idx = (cur_idx + 1) % len(images)
        direction = 1
    elif action == "prev":
        cur_idx = (cur_idx - 1 + len(images)) % len(images)
        direction = -1
    else: # "get" or "auto"
        cur_idx = cur_idx % len(images)

    state["index"] = cur_idx
    save_state(state)

    item = images[cur_idx]
    print(json.dumps({
        "path": item["path"],
        "title": item["title"],
        "subtitle": item["subtitle"],
        "index": cur_idx + 1,
        "total": len(images),
        "direction": direction
    }))

if __name__ == "__main__":
    main()
