#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — macOS Theme Mode (Dark/Light) Watcher for Eww
# ==============================================================================

import os
import sys
import time
import subprocess

SCHEME_FILE = os.path.expanduser("~/.config/lunita/color_scheme")

def get_current_theme_mode():
    if os.path.exists(SCHEME_FILE):
        try:
            with open(SCHEME_FILE, "r") as f:
                content = f.read().strip().lower()
                if "light" in content:
                    return "light"
                return "dark"
        except Exception:
            pass

    try:
        res = subprocess.run(
            ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"],
            capture_output=True, text=True, timeout=1
        )
        if "prefer-light" in res.stdout.lower() or "light" in res.stdout.lower():
            return "light"
    except Exception:
        pass

    return "dark"

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "get"

    if action == "get":
        print(get_current_theme_mode())
        return

    # Watch mode: stream changes
    last_mode = None
    while True:
        current_mode = get_current_theme_mode()
        if current_mode != last_mode:
            print(current_mode, flush=True)
            last_mode = current_mode
        time.sleep(0.3)

if __name__ == "__main__":
    main()
