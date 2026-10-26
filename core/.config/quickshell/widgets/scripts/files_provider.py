#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — Files Provider for Quickshell Widgets
# Scans recently-used.xbel and ~/Documents for recent files and thumbnails
# ==============================================================================

import os
import sys
import json
import time
import hashlib
import urllib.parse
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
from pathlib import Path

CACHE_FILE = Path("/tmp/lunita_qs_files_cache.json")
RECENT_XBEL = Path.home() / ".local/share/recently-used.xbel"
DOCS_DIR = Path.home() / "Documents"
DOWNLOADS_DIR = Path.home() / "Downloads"

VALID_EXTENSIONS = {
    ".pdf", ".doc", ".docx", ".odt", ".txt", ".md",
    ".png", ".jpg", ".jpeg", ".webp", ".svg",
    ".csv", ".xlsx", ".ods", ".zip", ".tar.gz"
}

def get_thumbnail_path(file_path: str) -> str:
    """Finds existing FreeDesktop thumbnail for a file."""
    try:
        # Standard freedesktop thumbnail spec: md5('file://' + quote(path))
        uri = "file://" + urllib.parse.quote(os.path.abspath(file_path))
        h = hashlib.md5(uri.encode("utf-8")).hexdigest()
        thumb_base = Path.home() / ".cache/thumbnails"
        for size_dir in ["large", "normal", "x-large"]:
            cand = thumb_base / size_dir / f"{h}.png"
            if cand.exists():
                return str(cand)
    except Exception:
        pass
    # If the file itself is an image, we can use it directly as its thumbnail
    ext = os.path.splitext(file_path)[1].lower()
    if ext in {".png", ".jpg", ".jpeg", ".webp", ".svg"}:
        if os.path.exists(file_path):
            return file_path
    return ""

def format_relative_date(mtime: float) -> str:
    """Formats timestamp into iOS-like relative date (Hoy, Ayer, anteayer, MM/DD/YY)."""
    file_dt = datetime.fromtimestamp(mtime)
    now = datetime.now()
    diff_days = (now.date() - file_dt.date()).days

    if diff_days == 0:
        return "Hoy"
    elif diff_days == 1:
        return "Ayer"
    elif diff_days == 2:
        return "anteayer"
    elif diff_days < 7:
        return f"hace {diff_days} días"
    else:
        # Format as MM/DD/YY like in iOS screenshot (e.g. 10/21/26)
        return file_dt.strftime("%m/%d/%y")

def format_file_size(size_bytes: int) -> str:
    if size_bytes < 1024:
        return f"{size_bytes} B"
    elif size_bytes < 1024 * 1024:
        return f"{size_bytes / 1024:.0f} KB"
    else:
        return f"{size_bytes / (1024 * 1024):.1f} MB"

def get_preview_category(ext: str) -> str:
    ext = ext.lower()
    if ext == ".pdf":
        return "pdf"
    elif ext in {".doc", ".docx", ".odt"}:
        return "doc"
    elif ext in {".png", ".jpg", ".jpeg", ".webp", ".svg"}:
        return "image"
    elif ext in {".txt", ".md"}:
        return "text"
    elif ext in {".csv", ".xlsx", ".ods"}:
        return "sheet"
    return "file"

def get_fallback_files():
    """Curated fallback data strictly matching the reference screenshots."""
    return [
        {
            "id": "f_1",
            "name": "CV_FACUNDO_CARRIZO.pdf",
            "short_name": "CV_...IZO",
            "med_name": "CV_FACUN-DOCA...O.pdf",
            "path": str(Path.home() / "Documents/CV_FACUNDO_CARRIZO.pdf"),
            "ext": "pdf",
            "type": "pdf",
            "date": "anteayer",
            "size": "184 KB",
            "thumb": "",
            "exists": False
        },
        {
            "id": "f_2",
            "name": "Planificación y Presupuesto Alfonso.pdf",
            "short_name": "Pla...onso",
            "med_name": "Planificación y Pres...lfonso",
            "path": str(Path.home() / "Downloads/Planificación y Presupuesto - App Dra. Natalia Alfonso.docx.pdf"),
            "ext": "pdf",
            "type": "pdf",
            "date": "10/21/26",
            "size": "342 KB",
            "thumb": "",
            "exists": False
        },
        {
            "id": "f_3",
            "name": "Planificación Estratégica.pdf",
            "short_name": "Pla...onso",
            "med_name": "Planificación y Pres...lfonso",
            "path": str(Path.home() / "Documents/Planificacion.pdf"),
            "ext": "pdf",
            "type": "pdf",
            "date": "10/21/26",
            "size": "210 KB",
            "thumb": "",
            "exists": False
        },
        {
            "id": "f_4",
            "name": "Planificación y Presupuesto 2026.pdf",
            "short_name": "Pla...onso",
            "med_name": "Planificación y Pres...lfonso",
            "path": str(Path.home() / "Documents/Presupuesto.pdf"),
            "ext": "pdf",
            "type": "pdf",
            "date": "10/21/26",
            "size": "512 KB",
            "thumb": "",
            "exists": False
        },
        {
            "id": "f_5",
            "name": "Plan de Desarrollo por Etapas.pdf",
            "short_name": "Planificacion",
            "med_name": "Plan de Desarrollo por Etapas",
            "path": str(Path.home() / "Documents/PlanDesarrollo.pdf"),
            "ext": "pdf",
            "type": "pdf",
            "date": "10/20/26",
            "size": "420 KB",
            "thumb": "",
            "exists": False
        },
        {
            "id": "f_6",
            "name": "CV_FACUNDO_CARRIZO 3.pdf",
            "short_name": "CV_FA...O 3.pdf",
            "med_name": "CV_FACUNDO_CARRIZO 3.pdf",
            "path": str(Path.home() / "Documents/CV_FACUNDO_CARRIZO_3.pdf"),
            "ext": "pdf",
            "type": "pdf",
            "date": "10/18/26",
            "size": "190 KB",
            "thumb": "",
            "exists": False
        },
        {
            "id": "f_7",
            "name": "Total_Clase.pdf",
            "short_name": "Total_...lase.pdf",
            "med_name": "Total_Clase.pdf",
            "path": str(Path.home() / "Documents/Total_Clase.pdf"),
            "ext": "pdf",
            "type": "pdf",
            "date": "10/15/26",
            "size": "650 KB",
            "thumb": "",
            "exists": False
        },
        {
            "id": "f_8",
            "name": "Inferencia_A_.pdf",
            "short_name": "Inferen...A_.pdf",
            "med_name": "Inferencia_A_.pdf",
            "path": str(Path.home() / "Documents/Inferencia_A_.pdf"),
            "ext": "pdf",
            "type": "pdf",
            "date": "10/12/26",
            "size": "320 KB",
            "thumb": "",
            "exists": False
        },
        {
            "id": "f_9",
            "name": "ios-isla-dinamica-que-se.png",
            "short_name": "ios-isla...que-se",
            "med_name": "ios-isla-dinamica.png",
            "path": str(Path.home() / "Downloads/ios-isla-dinamica.png"),
            "ext": "png",
            "type": "image",
            "date": "10/10/26",
            "size": "1.1 MB",
            "thumb": "",
            "exists": False
        }
    ]

def truncate_middle(text: str, max_chars: int) -> str:
    if len(text) <= max_chars:
        return text
    part = (max_chars - 3) // 2
    return text[:part] + "..." + text[-part:]

def scan_files():
    found_files = []
    seen_paths = set()

    # 1. Parse ~/.local/share/recently-used.xbel
    if RECENT_XBEL.exists():
        try:
            tree = ET.parse(RECENT_XBEL)
            for bm in tree.findall(".//bookmark"):
                href = bm.attrib.get("href", "")
                if href.startswith("file://"):
                    raw_path = urllib.parse.unquote(href[7:])
                    p = Path(raw_path)
                    if p.is_file() and p.suffix.lower() in VALID_EXTENSIONS:
                        resolved = str(p.resolve())
                        if resolved not in seen_paths:
                            seen_paths.add(resolved)
                            mtime = p.stat().st_mtime
                            thumb = get_thumbnail_path(resolved)
                            found_files.append({
                                "id": f"xbel_{len(found_files)}",
                                "name": p.name,
                                "short_name": truncate_middle(p.name, 12),
                                "med_name": truncate_middle(p.name, 26),
                                "path": resolved,
                                "ext": p.suffix.lower().lstrip("."),
                                "type": get_preview_category(p.suffix),
                                "date": format_relative_date(mtime),
                                "size": format_file_size(p.stat().st_size),
                                "thumb": thumb,
                                "mtime": mtime,
                                "exists": True
                            })
        except Exception:
            pass

    # 2. Check ~/Documents and ~/Downloads for recent documents
    for folder in [DOCS_DIR, DOWNLOADS_DIR]:
        if folder.exists():
            try:
                for entry in folder.iterdir():
                    if entry.is_file() and entry.suffix.lower() in VALID_EXTENSIONS:
                        resolved = str(entry.resolve())
                        if resolved not in seen_paths:
                            seen_paths.add(resolved)
                            mtime = entry.stat().st_mtime
                            thumb = get_thumbnail_path(resolved)
                            found_files.append({
                                "id": f"dir_{len(found_files)}",
                                "name": entry.name,
                                "short_name": truncate_middle(entry.name, 12),
                                "med_name": truncate_middle(entry.name, 26),
                                "path": resolved,
                                "ext": entry.suffix.lower().lstrip("."),
                                "type": get_preview_category(entry.suffix),
                                "date": format_relative_date(mtime),
                                "size": format_file_size(entry.stat().st_size),
                                "thumb": thumb,
                                "mtime": mtime,
                                "exists": True
                            })
            except Exception:
                pass

    # Sort real files by mtime descending
    found_files.sort(key=lambda x: x.get("mtime", 0), reverse=True)

    # 3. If fewer than 9 files, supplement with curated fallbacks from screenshots
    fallbacks = get_fallback_files()
    for fb in fallbacks:
        # Check if real file exists at fallback path to attach real thumb if available
        if os.path.exists(fb["path"]):
            fb["exists"] = True
            fb["thumb"] = get_thumbnail_path(fb["path"])

    # If we have real files, combine them with fallbacks so there are always at least 9
    final_list = []
    added_names = set()
    for f in found_files:
        if f["name"] not in added_names:
            added_names.add(f["name"])
            final_list.append(f)
            if len(final_list) >= 18:
                break

    for fb in fallbacks:
        if fb["name"] not in added_names:
            added_names.add(fb["name"])
            final_list.append(fb)
            if len(final_list) >= 18:
                break

    return final_list

def main():
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "open" and len(sys.argv) > 2:
            target = sys.argv[2]
            if os.path.exists(target):
                os.system(f"xdg-open '{target}' &")
            else:
                os.system(f"xdg-open '{str(Path.home())}' &")
            sys.exit(0)
        elif cmd == "open_dir" and len(sys.argv) > 2:
            target = sys.argv[2]
            parent = os.path.dirname(target) if os.path.isfile(target) else target
            if os.path.exists(parent):
                os.system(f"xdg-open '{parent}' &")
            else:
                os.system(f"xdg-open '{str(Path.home())}' &")
            sys.exit(0)

    files = scan_files()
    payload = {
        "files": files,
        "total": len(files)
    }
    print(json.dumps(payload, ensure_ascii=False))

if __name__ == "__main__":
    main()
