#!/usr/bin/env python3
"""Resolve SystemTray icon references (image://qsimage, image://icon, paths, names) to valid QML Image URLs."""

from pathlib import Path
import sys
from urllib.parse import parse_qs, urlparse


def resolve_icon(raw_icon: str) -> str:
    if not raw_icon:
        return ""

    if raw_icon.startswith("image://qsimage/") or raw_icon.startswith("file://"):
        return raw_icon

    custom_path = ""
    icon_name = raw_icon

    if raw_icon.startswith("image://icon/"):
        parsed = urlparse(raw_icon)
        icon_name = parsed.netloc or parsed.path.lstrip("/")
        if parsed.query:
            qs = parse_qs(parsed.query)
            if "path" in qs and qs["path"]:
                custom_path = qs["path"][0]
    elif "?" in raw_icon:
        parts = raw_icon.split("?", 1)
        icon_name = parts[0]
        qs = parse_qs(parts[1])
        if "path" in qs and qs["path"]:
            custom_path = qs["path"][0]

    candidate_path = Path(icon_name)
    if candidate_path.is_absolute() and candidate_path.is_file():
        return f"file://{candidate_path}"

    search_dirs: list[Path] = []
    if custom_path:
        cp = Path(custom_path)
        if cp.is_file():
            return f"file://{cp}"
        if cp.is_dir():
            search_dirs.append(cp)

    home = Path.home()
    search_dirs.extend([
        home / ".local/share/icons/hicolor/scalable/apps",
        home / ".local/share/icons/hicolor/48x48/apps",
        home / ".local/share/icons/hicolor/32x32/apps",
        home / ".local/share/icons",
        Path("/usr/share/icons/Papirus-Dark/24x24/panel"),
        Path("/usr/share/icons/Papirus/24x24/panel"),
        Path("/usr/share/icons/Papirus/48x48/apps"),
        Path("/usr/share/icons/Papirus/32x32/apps"),
        Path("/usr/share/icons/hicolor/scalable/apps"),
        Path("/usr/share/icons/hicolor/256x256/apps"),
        Path("/usr/share/icons/hicolor/128x128/apps"),
        Path("/usr/share/icons/hicolor/64x64/apps"),
        Path("/usr/share/icons/hicolor/48x48/apps"),
        Path("/usr/share/icons/hicolor/32x32/apps"),
        Path("/usr/share/icons/hicolor/24x24/apps"),
        Path("/usr/share/icons/hicolor/22x22/apps"),
        Path("/usr/share/icons/hicolor/16x16/apps"),
        Path("/usr/share/pixmaps"),
    ])

    extensions = ["", ".svg", ".png", ".xpm"]

    for d in search_dirs:
        if not d.exists():
            continue
        for ext in extensions:
            full_path = d / f"{icon_name}{ext}"
            if full_path.is_file():
                return f"file://{full_path}"
        if custom_path and d == Path(custom_path):
            for ext in (".svg", ".png"):
                for match in d.rglob(f"{icon_name}{ext}"):
                    if match.is_file():
                        return f"file://{match}"

    if icon_name:
        return f"image://icon/{icon_name}"
    return ""


def main() -> None:
    if len(sys.argv) < 2:
        sys.exit(0)
    if sys.argv[1] == "--batch":
        for raw in sys.argv[2:]:
            if not raw:
                continue
            resolved = resolve_icon(raw)
            if resolved:
                print(f"{raw}|{resolved}")
    else:
        resolved = resolve_icon(sys.argv[1])
        if resolved:
            print(resolved)


if __name__ == "__main__":
    main()
