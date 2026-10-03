#!/usr/bin/env python3
"""
macOS-Style Clipboard Manager Backend for Quickshell
Handles cliphist listing, timestamp mapping, item categorization,
copying, pasting, and deletion.
"""

import sys
import os
import re
import json
import subprocess
import time
from urllib.parse import urlparse
from datetime import datetime

CACHE_DIR = os.path.expanduser("~/.cache/cliphist")
TS_FILE = os.path.join(CACHE_DIR, "timestamps.tsv")
THUMB_DIR = os.path.join(CACHE_DIR, "thumbs")

os.makedirs(CACHE_DIR, exist_ok=True)
os.makedirs(THUMB_DIR, exist_ok=True)

def load_timestamps():
    timestamps = {}
    if os.path.exists(TS_FILE):
        try:
            with open(TS_FILE, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    parts = line.strip().split("\t")
                    if len(parts) >= 2:
                        timestamps[parts[0]] = int(parts[1])
        except Exception:
            pass
    return timestamps

def format_timestamp(ts, now):
    if not ts:
        return "Copied Recently"
    try:
        dt = datetime.fromtimestamp(ts)
        diff_days = (now.date() - dt.date()).days
        time_part = dt.strftime("%-I:%M %p")
        if diff_days == 0:
            return f"Copied {time_part}"
        elif diff_days == 1:
            return f"Copied Yesterday {time_part}"
        else:
            return f"Copied {dt.strftime('%b %d')} {time_part}"
    except Exception:
        return "Copied Recently"

def extract_domain(url_str):
    url = url_str.strip()
    if not url.startswith(("http://", "https://")):
        url = "https://" + url
    try:
        parsed = urlparse(url)
        return parsed.netloc or parsed.path.split("/")[0]
    except Exception:
        return "web"

def cmd_list(query=""):
    timestamps = load_timestamps()
    now = datetime.now()

    try:
        out = subprocess.check_output(["cliphist", "list"], text=True, errors="replace")
    except Exception:
        out = ""

    lines = [l for l in out.strip().split("\n") if l]
    items = []
    q = query.lower().strip()

    for line in lines:
        parts = line.split("\t", 1)
        item_id = parts[0]
        preview = parts[1] if len(parts) > 1 else ""

        if not preview.strip():
            continue

        if q and q not in preview.lower():
            continue

        ts = timestamps.get(item_id)
        time_str = format_timestamp(ts, now)
        clean = preview.strip()

        is_url = bool(re.match(r"^https?://", clean, re.I)) or bool(re.match(r"^www\.", clean, re.I))
        is_image = clean.startswith("[[ binary data")

        thumbnail_path = ""
        if is_url:
            item_type = "url"
            domain = extract_domain(clean)
            subtitle = f"URL · {domain} · {time_str}"
            icon = "safari"
        elif is_image:
            item_type = "image"
            subtitle = f"Image · {time_str}"
            icon = "photo"
            # Generate thumbnail if not cached
            cached_thumb = os.path.join(THUMB_DIR, f"{item_id}.png")
            if not os.path.exists(cached_thumb):
                try:
                    p1 = subprocess.Popen(["cliphist", "list"], stdout=subprocess.PIPE, text=True)
                    p2 = subprocess.Popen(["grep", "-m1", "-E", f"^{item_id}\t"], stdin=p1.stdout, stdout=subprocess.PIPE)
                    p1.stdout.close()
                    with open(cached_thumb, "wb") as f_thumb:
                        subprocess.run(["cliphist", "decode"], stdin=p2.stdout, stdout=f_thumb, timeout=1.0)
                    p2.stdout.close()
                except Exception:
                    pass
            if os.path.exists(cached_thumb) and os.path.getsize(cached_thumb) > 0:
                thumbnail_path = "file://" + cached_thumb
        elif clean.startswith(("git ", "sudo ", "pacman ", "yay ", "cargo ", "npm ", "docker ", "curl ", "export ", "python ", "cat ", "ls ", "grep ", "ssh ", "make ")):
            item_type = "code"
            subtitle = f"Terminal · {time_str}"
            icon = "terminal"
        elif any(sym in clean for sym in ["{", "}", "=>", "const ", "def ", "function", "import "]) and "\n" in clean:
            item_type = "code"
            subtitle = f"Code · {time_str}"
            icon = "code"
        else:
            item_type = "text"
            subtitle = f"Text · {time_str}"
            icon = "document"

        # Truncate first line for clean preview in title
        title_line = clean.split("\n")[0].strip()

        items.append({
            "id": item_id,
            "title": title_line,
            "preview": clean,
            "type": item_type,
            "subtitle": subtitle,
            "icon": icon,
            "thumbnail": thumbnail_path,
        })

        if len(items) >= 60:
            break

    print(json.dumps({"items": items}))

def cmd_copy(item_id):
    try:
        p1 = subprocess.Popen(["cliphist", "list"], stdout=subprocess.PIPE, text=True)
        p2 = subprocess.Popen(["grep", "-m1", "-E", f"^{item_id}\t"], stdin=p1.stdout, stdout=subprocess.PIPE)
        p1.stdout.close()
        p3 = subprocess.Popen(["cliphist", "decode"], stdin=p2.stdout, stdout=subprocess.PIPE)
        p2.stdout.close()
        subprocess.run(["wl-copy"], stdin=p3.stdout)
        p3.stdout.close()

        # Update timestamp to now
        now_ts = int(time.time())
        try:
            with open(TS_FILE, "a", encoding="utf-8") as f:
                f.write(f"{item_id}\t{now_ts}\n")
        except Exception:
            pass
        return True
    except Exception as e:
        print(f"Error copying {item_id}: {e}", file=sys.stderr)
        return False

def cmd_paste(item_id):
    if cmd_copy(item_id):
        # Allow Wayland window to lose focus and compositor to update active client
        time.sleep(0.08)
        try:
            subprocess.run(["wtype", "-M", "ctrl", "-k", "v", "-m", "ctrl"])
        except Exception:
            pass

def cmd_delete(item_id):
    try:
        p1 = subprocess.Popen(["cliphist", "list"], stdout=subprocess.PIPE, text=True)
        p2 = subprocess.Popen(["grep", "-m1", "-E", f"^{item_id}\t"], stdin=p1.stdout, stdout=subprocess.PIPE)
        p1.stdout.close()
        subprocess.run(["cliphist", "delete"], stdin=p2.stdout)
        p2.stdout.close()
    except Exception as e:
        print(f"Error deleting {item_id}: {e}", file=sys.stderr)

def cmd_clear():
    try:
        subprocess.run(["cliphist", "wipe"], check=False)
        if os.path.exists(TS_FILE):
            os.remove(TS_FILE)
        for f in os.listdir(THUMB_DIR):
            try:
                os.remove(os.path.join(THUMB_DIR, f))
            except Exception:
                pass
    except Exception as e:
        print(f"Error clearing: {e}", file=sys.stderr)

def main():
    if len(sys.argv) < 2:
        cmd_list()
        return

    action = sys.argv[1]
    if action == "list":
        q = sys.argv[2] if len(sys.argv) > 2 else ""
        cmd_list(q)
    elif action == "copy":
        if len(sys.argv) > 2:
            cmd_copy(sys.argv[2])
    elif action == "paste":
        if len(sys.argv) > 2:
            cmd_paste(sys.argv[2])
    elif action == "delete":
        if len(sys.argv) > 2:
            cmd_delete(sys.argv[2])
    elif action == "clear" or action == "wipe":
        cmd_clear()
    else:
        cmd_list(action)

if __name__ == "__main__":
    main()
