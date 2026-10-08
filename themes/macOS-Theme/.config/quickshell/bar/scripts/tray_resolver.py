#!/usr/bin/env python3
import sys, os, glob, json

search_dirs = [
    os.path.expanduser("~/.local/share/icons"),
    os.path.expanduser("~/.icons"),
    "/usr/share/icons",
    "/usr/share/pixmaps"
]
themes = ["BeautyLine", "hicolor", "breeze", "Adwaita"]
exts = [".svg", ".png", ".xpm"]

def resolve_single(icon_name):
    if not icon_name:
        return ""
    clean = icon_name.split("?")[0]
    if clean.startswith("/") or clean.startswith("file://"):
        return clean if clean.startswith("file://") else "file://" + clean

    # 1. Search in preferred themes
    for base in search_dirs:
        for theme in themes:
            theme_dir = os.path.join(base, theme)
            if not os.path.isdir(theme_dir):
                continue
            for ext in exts:
                pattern = os.path.join(theme_dir, "**", f"{clean}{ext}")
                matches = glob.glob(pattern, recursive=True)
                if matches:
                    return "file://" + matches[0]

    # 2. General search
    for base in search_dirs:
        for ext in exts:
            pattern = os.path.join(base, "**", f"{clean}{ext}")
            matches = glob.glob(pattern, recursive=True)
            if matches:
                return "file://" + matches[0]
    return ""

if __name__ == "__main__":
    icons = sys.argv[1:]
    res = {}
    for ic in icons:
        resolved = resolve_single(ic)
        if resolved:
            res[ic] = resolved
    print(json.dumps(res))
