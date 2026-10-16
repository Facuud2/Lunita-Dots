#!/usr/bin/env python3
"""
SystemTray Icon Resolver for Quickshell Status Bar.
Handles Quickshell image://qsimage/, image://icon/<name>?path=...,
and standard Freedesktop icon themes using pathlib.Path.
"""

import json
import os
import sys
from pathlib import Path
from urllib.parse import parse_qs, urlparse

HOME_DIR = Path.home()
SEARCH_DIRS = [
    HOME_DIR / ".local/share/icons",
    HOME_DIR / ".icons",
    HOME_DIR / ".local/share/flatpak/exports/share/icons",
    Path("/var/lib/flatpak/exports/share/icons"),
    Path("/usr/share/icons"),
    Path("/usr/share/pixmaps"),
]
THEMES = ["BeautyLine", "hicolor", "breeze-dark", "breeze", "Adwaita", "Papirus", "Papirus-Dark"]
EXTS = (".svg", ".png", ".xpm")


def find_in_directory(directory: Path, icon_stem: str) -> str:
    if not directory.is_dir():
        return ""
    for ext in EXTS:
        direct = directory / f"{icon_stem}{ext}"
        if direct.is_file():
            return f"file://{direct}"
    for ext in EXTS:
        try:
            for match in directory.rglob(f"{icon_stem}{ext}"):
                if match.is_file():
                    return f"file://{match}"
        except Exception:
            pass
    return ""


def resolve_single(icon_spec: str) -> str:
    if not icon_spec:
        return ""

    if icon_spec.startswith("image://qsimage/"):
        return icon_spec

    custom_paths: list[Path] = []
    clean = icon_spec

    if "?" in icon_spec:
        base_part, query_part = icon_spec.split("?", 1)
        clean = base_part
        qs = parse_qs(query_part)
        for p_str in qs.get("path", []):
            if p_str:
                custom_paths.append(Path(p_str))

    if clean.startswith("image://icon/"):
        clean = clean[len("image://icon/") :]
    elif clean.startswith("file://"):
        clean = clean[len("file://") :]

    clean = clean.strip()
    if not clean:
        return icon_spec

    clean_path = Path(clean)
    if clean_path.is_absolute():
        if clean_path.is_file():
            return f"file://{clean_path}"
        for ext in EXTS:
            candidate = Path(f"{clean}{ext}")
            if candidate.is_file():
                return f"file://{candidate}"

    # 1. Check custom SNI IconThemePath first if provided
    for cpath in custom_paths:
        found = find_in_directory(cpath, clean)
        if found:
            return found

    # 2. Search in preferred icon themes
    for base in SEARCH_DIRS:
        if not base.is_dir():
            continue
        for theme in THEMES:
            found = find_in_directory(base / theme, clean)
            if found:
                return found

    # 3. Search directly in pixmaps / base icon directories
    for base in SEARCH_DIRS:
        found = find_in_directory(base, clean)
        if found:
            return found

    # 4. Fallback to Quickshell's built-in icon provider
    if icon_spec.startswith("image://"):
        return icon_spec
    return f"image://icon/{clean}"


def main() -> None:
    icons = sys.argv[1:]
    res: dict[str, str] = {}
    for ic in icons:
        resolved = resolve_single(ic)
        if resolved:
            res[ic] = resolved
    print(json.dumps(res))


if __name__ == "__main__":
    main()
