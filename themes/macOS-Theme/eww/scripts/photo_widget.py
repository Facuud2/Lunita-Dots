#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — macOS Photos & Memories Widget Provider
# Recursively scans ~/Imagenes/* (including all subdirectories)
# ==============================================================================

import os
import sys
import json
import time
import hashlib
import subprocess

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
FALLBACK_ASSETS_DIR = os.path.join(SCRIPT_DIR, "..", "assets", "photos")
STATE_FILE = "/tmp/lunita_photos_widget_state.json"
CACHE_DIR = os.path.expanduser("~/.cache/eww/photos")

VALID_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".jfif"}

SEARCH_DIRS = [
    os.path.expanduser("~/Imagenes"),
    os.path.expanduser("~/Imágenes"),
    "/Imagenes",
    os.path.expanduser("~/Pictures")
]

def ensure_cache_dir():
    os.makedirs(CACHE_DIR, exist_ok=True)

def get_all_images():
    images = []
    seen_paths = set()

    for base_dir in SEARCH_DIRS:
        if not os.path.exists(base_dir):
            continue

        for root, _, files in os.walk(base_dir):
            for f in sorted(files):
                ext = os.path.splitext(f)[1].lower()
                if ext in VALID_EXTENSIONS:
                    full_path = os.path.abspath(os.path.join(root, f))
                    if full_path not in seen_paths:
                        seen_paths.add(full_path)
                        rel_folder = os.path.basename(root)
                        if rel_folder in ["Imagenes", "Imágenes", "Pictures", ""]:
                            category = "Recuerdos"
                        else:
                            category = rel_folder
                        
                        images.append({
                            "path": full_path,
                            "filename": f,
                            "category": category,
                            "title": format_title(f)
                        })

    # Fallback to local default assets if folder has no images
    if not images and os.path.exists(FALLBACK_ASSETS_DIR):
        for f in sorted(os.listdir(FALLBACK_ASSETS_DIR)):
            ext = os.path.splitext(f)[1].lower()
            if ext in VALID_EXTENSIONS:
                full_path = os.path.abspath(os.path.join(FALLBACK_ASSETS_DIR, f))
                images.append({
                    "path": full_path,
                    "filename": f,
                    "category": "Destacados",
                    "title": format_title(f)
                })

    return images

def format_title(filename):
    name_without_ext = os.path.splitext(filename)[0]
    clean = name_without_ext.replace("_", " ").replace("-", " ")
    
    # Capitalize words cleanly
    if len(clean) > 28:
        clean = clean[:26] + "..."
    return clean

def get_thumbnail(src_path):
    ensure_cache_dir()
    if not os.path.exists(src_path):
        return src_path

    h = hashlib.md5(src_path.encode("utf-8")).hexdigest()[:14]
    thumb_path = os.path.join(CACHE_DIR, f"thumb_{h}.jpg")

    if not os.path.exists(thumb_path):
        try:
            # Crop to 708x352 (2:1 aspect ratio matching the widget frame)
            subprocess.run(
                [
                    "magick", src_path,
                    "-resize", "708x352^",
                    "-gravity", "center",
                    "-extent", "708x352",
                    thumb_path
                ],
                check=True,
                timeout=2,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        except Exception:
            return src_path

    return thumb_path

def load_state():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return {"index": 0}

def save_state(state):
    try:
        with open(STATE_FILE, "w") as f:
            json.dump(state, f)
    except Exception:
        pass

def get_payload():
    images = get_all_images()
    if not images:
        return {
            "path": "",
            "raw_path": "",
            "title": "Sin Imágenes",
            "subtitle": "Recuerdos",
            "index": 0,
            "total": 0
        }

    state = load_state()
    idx = state.get("index", 0) % len(images)
    current_item = images[idx]

    thumb_path = get_thumbnail(current_item["path"])

    return {
        "path": thumb_path,
        "raw_path": current_item["path"],
        "title": current_item["title"],
        "subtitle": current_item["category"],
        "index": idx + 1,
        "total": len(images)
    }

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "get"

    if action == "get":
        print(json.dumps(get_payload()))
    elif action == "next":
        images = get_all_images()
        if images:
            state = load_state()
            state["index"] = (state.get("index", 0) + 1) % len(images)
            save_state(state)
            payload = get_payload()
            try:
                subprocess.run(["eww", "update", f"photo_data={json.dumps(payload)}"], check=False)
            except Exception:
                pass
            print(json.dumps(payload))
    elif action == "prev":
        images = get_all_images()
        if images:
            state = load_state()
            state["index"] = (state.get("index", 0) - 1 + len(images)) % len(images)
            save_state(state)
            payload = get_payload()
            try:
                subprocess.run(["eww", "update", f"photo_data={json.dumps(payload)}"], check=False)
            except Exception:
                pass
            print(json.dumps(payload))
    elif action == "open":
        payload = get_payload()
        raw = payload.get("raw_path") or payload.get("path")
        if raw and os.path.exists(raw):
            subprocess.Popen(["xdg-open", raw])
    elif action == "watch":
        last_idx = -1
        last_total = -1
        while True:
            payload = get_payload()
            cur_idx = payload.get("index")
            cur_tot = payload.get("total")
            
            if cur_idx != last_idx or cur_tot != last_total:
                print(json.dumps(payload), flush=True)
                last_idx = cur_idx
                last_total = cur_tot
            
            time.sleep(1.0)

if __name__ == "__main__":
    main()
