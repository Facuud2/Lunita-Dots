#!/usr/bin/env python3
"""
Lunita macOS Desktop Widgets - Safari Reading List Provider
Manages featured articles, bookmarks, and links with rich previews.
"""

import sys
import os
import json
import subprocess

READING_FILE = os.path.expanduser("~/.local/share/lunita/reading_list.json")
STATE_FILE = os.path.expanduser("~/.local/share/lunita/reading_state.json")
ASSETS_DIR = os.path.expanduser("~/.config/eww/assets")

DEFAULT_ITEMS = [
    {
        "id": 1,
        "title": "India Trip - Group Travel | Atlas Obscura Adventures",
        "domain": "atlasobscura.com",
        "url": "https://www.atlasobscura.com/unusual-trips",
        "image": "reading_cover_1.jpg",
        "category": "Reading List"
    },
    {
        "id": 2,
        "title": "Hyprland — An intelligent dynamic tiling Wayland compositor",
        "domain": "hyprland.org",
        "url": "https://hyprland.org",
        "image": "reading_cover_2.jpg",
        "category": "Safari Bookmarks"
    },
    {
        "id": 3,
        "title": "macOS Sonoma Widgets on Linux Desktop Experience",
        "domain": "lunita.io",
        "url": "https://github.com/Facuud2/Lunita-Dots",
        "image": "reading_cover_3.jpg",
        "category": "Favorites"
    }
]

def load_items():
    if not os.path.exists(READING_FILE):
        os.makedirs(os.path.dirname(READING_FILE), exist_ok=True)
        with open(READING_FILE, "w", encoding="utf-8") as f:
            json.dump(DEFAULT_ITEMS, f, indent=2, ensure_ascii=False)
        return DEFAULT_ITEMS
    try:
        with open(READING_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return DEFAULT_ITEMS

def get_current_index(total):
    if not os.path.exists(STATE_FILE):
        return 0
    try:
        with open(STATE_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            return data.get("index", 0) % max(1, total)
    except Exception:
        return 0

def save_current_index(index):
    os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
    with open(STATE_FILE, "w", encoding="utf-8") as f:
        json.dump({"index": index}, f)

def get_item():
    items = load_items()
    if not items:
        return {
            "title": "Sin lecturas guardadas",
            "domain": "safari.app",
            "url": "https://google.com",
            "image": "",
            "category": "Reading List"
        }
    idx = get_current_index(len(items))
    item = items[idx]
    
    # Resolve image path
    img_name = item.get("image", "")
    if img_name and not os.path.isabs(img_name):
        full_img_path = os.path.join(ASSETS_DIR, img_name)
    else:
        full_img_path = img_name

    return {
        "title": item.get("title", "Safari Reading List"),
        "domain": item.get("domain", "apple.com"),
        "url": item.get("url", "https://apple.com"),
        "image": full_img_path if os.path.exists(full_img_path) else "",
        "category": item.get("category", "Reading List"),
        "index": idx + 1,
        "total": len(items)
    }

def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "get"
    
    if cmd == "get":
        print(json.dumps(get_item(), ensure_ascii=False))
        sys.stdout.flush()
    elif cmd == "next":
        items = load_items()
        if items:
            cur = get_current_index(len(items))
            save_current_index((cur + 1) % len(items))
            # Trigger eww update
            subprocess.run(["eww", "update", f"reading_data={json.dumps(get_item(), ensure_ascii=False)}"], check=False)
            print(json.dumps(get_item(), ensure_ascii=False))
    elif cmd == "prev":
        items = load_items()
        if items:
            cur = get_current_index(len(items))
            save_current_index((cur - 1 + len(items)) % len(items))
            subprocess.run(["eww", "update", f"reading_data={json.dumps(get_item(), ensure_ascii=False)}"], check=False)
            print(json.dumps(get_item(), ensure_ascii=False))
    elif cmd == "open":
        item = get_item()
        url = item.get("url")
        if url:
            subprocess.Popen(["xdg-open", url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

if __name__ == "__main__":
    main()
