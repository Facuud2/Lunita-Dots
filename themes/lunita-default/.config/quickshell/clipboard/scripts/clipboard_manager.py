#!/usr/bin/env python3
"""
Nothing OS / Lunita-Default Clipboard Manager Backend for Quickshell
Handles cliphist listing, Spanish timestamp mapping, item categorization,
copying, terminal-aware auto-pasting, and deletion.
"""

import json
import os
import re
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path
from urllib.parse import urlparse

HOME_DIR = Path.home()
CACHE_DIR = Path(os.getenv("XDG_CACHE_HOME", str(HOME_DIR / ".cache"))) / "cliphist"
TS_FILE = CACHE_DIR / "timestamps.tsv"
THUMB_DIR = CACHE_DIR / "thumbs"

CACHE_DIR.mkdir(parents=True, exist_ok=True)
THUMB_DIR.mkdir(parents=True, exist_ok=True)


def load_timestamps() -> dict[str, int]:
    timestamps: dict[str, int] = {}
    if TS_FILE.is_file():
        try:
            for line in TS_FILE.read_text(encoding="utf-8", errors="ignore").splitlines():
                parts = line.strip().split("\t")
                if len(parts) >= 2:
                    timestamps[parts[0].strip()] = int(parts[1].strip())
        except Exception:
            pass
    return timestamps


def format_timestamp(ts: int | None, now: datetime) -> str:
    if not ts:
        return f"Hoy, {now.strftime('%H:%M')}"
    try:
        dt = datetime.fromtimestamp(ts)
        time_part = dt.strftime("%H:%M")
        if dt.date() == now.date():
            return f"Hoy, {time_part}"
        return f"{dt.strftime('%d/%m')}, {time_part}"
    except Exception:
        return f"Hoy, {now.strftime('%H:%M')}"


def extract_domain(url_str: str) -> str:
    url = url_str.strip()
    if not url.startswith(("http://", "https://")):
        url = "https://" + url
    try:
        parsed = urlparse(url)
        return parsed.netloc or parsed.path.split("/")[0]
    except Exception:
        return "web"


def cmd_list(query: str = "") -> None:
    timestamps = load_timestamps()
    now = datetime.now()

    try:
        out = subprocess.check_output(["cliphist", "list"], text=True, errors="replace")
    except Exception:
        out = ""

    lines = [line for line in out.strip().split("\n") if line]
    items = []
    q = query.lower().strip()

    for line in lines:
        parts = line.split("\t", 1)
        item_id = parts[0].strip()
        preview = parts[1] if len(parts) > 1 else ""

        if not preview.strip():
            continue

        clean = preview.strip()
        ts = timestamps.get(item_id)
        time_str = format_timestamp(ts, now)

        bin_match = re.match(r"^\[\[\s*binary data\s+([^\]]+)\]\]", clean, re.I)
        is_image = bool(bin_match) or clean.startswith("[[ binary data")
        is_link = bool(re.match(r"^(https?://|www\.)\S+", clean, re.I))
        is_code = bool(
            re.match(
                r"^(curl|wget|git|sudo|pacman|systemctl|docker|ssh|cat|grep|npm|cargo|pip|hyprctl|echo|export|python3?|ls|make)\s",
                clean,
                re.I,
            )
            or re.search(
                r"(\{|\}|\(\)|=>|function\s|const\s|let\s|import\s|class\s|def\s|SELECT\s|return\s)",
                clean,
            )
        )

        thumbnail_path = ""
        if is_image:
            meta = bin_match.group(1).strip() if bin_match else "imagen"
            item_type = "image"
            tag = "IMAGEN"
            icon = "image"
            title_line = f"Captura / Imagen ({meta})"
            detail = "Imagen binaria guardada en portapapeles"
            cached_thumb = THUMB_DIR / f"{item_id}.png"
            if not cached_thumb.exists():
                try:
                    p1 = subprocess.Popen(["cliphist", "list"], stdout=subprocess.PIPE, text=True)
                    p2 = subprocess.Popen(
                        ["grep", "-m1", "-E", f"^{re.escape(item_id)}\t"],
                        stdin=p1.stdout,
                        stdout=subprocess.PIPE,
                    )
                    if p1.stdout:
                        p1.stdout.close()
                    with cached_thumb.open("wb") as f_thumb:
                        subprocess.run(
                            ["cliphist", "decode"],
                            stdin=p2.stdout,
                            stdout=f_thumb,
                            timeout=1.0,
                            check=False,
                        )
                    if p2.stdout:
                        p2.stdout.close()
                except Exception:
                    pass
            if cached_thumb.is_file() and cached_thumb.stat().st_size > 0:
                thumbnail_path = f"file://{cached_thumb}"
        elif is_link:
            item_type = "link"
            tag = "ENLACE"
            icon = "link"
            title_line = clean.split("\n")[0].strip()
            detail = f"Enlace Web ({extract_domain(clean)})"
        elif is_code:
            item_type = "code"
            tag = "CÓDIGO"
            icon = "code"
            title_line = clean.split("\n")[0].strip()
            detail = "Comando o bloque de código"
        else:
            item_type = "text"
            tag = "TEXTO"
            icon = "description"
            title_line = clean.split("\n")[0].strip()
            detail = "Texto plano copiado"

        if q and (
            q not in clean.lower()
            and q not in title_line.lower()
            and q not in detail.lower()
            and q not in tag.lower()
            and q not in time_str.lower()
        ):
            continue

        items.append(
            {
                "id": item_id,
                "title": title_line,
                "preview": clean,
                "type": item_type,
                "tag": tag,
                "timestamp": time_str,
                "subtitle": f"{tag} · {time_str}",
                "detail": detail,
                "icon": icon,
                "thumbnail": thumbnail_path,
            }
        )

        if len(items) >= 60:
            break

    print(json.dumps({"items": items}))


def cmd_copy(item_id: str) -> bool:
    try:
        p1 = subprocess.Popen(["cliphist", "list"], stdout=subprocess.PIPE, text=True)
        p2 = subprocess.Popen(
            ["grep", "-m1", "-E", f"^{re.escape(item_id)}\t"],
            stdin=p1.stdout,
            stdout=subprocess.PIPE,
        )
        if p1.stdout:
            p1.stdout.close()
        p3 = subprocess.Popen(["cliphist", "decode"], stdin=p2.stdout, stdout=subprocess.PIPE)
        if p2.stdout:
            p2.stdout.close()
        subprocess.run(["wl-copy"], stdin=p3.stdout, check=False)
        if p3.stdout:
            p3.stdout.close()

        now_ts = int(time.time())
        try:
            with TS_FILE.open("a", encoding="utf-8") as f:
                f.write(f"{item_id}\t{now_ts}\n")
        except Exception:
            pass
        return True
    except Exception as exc:
        print(f"Error copying {item_id}: {exc}", file=sys.stderr)
        return False


def cmd_paste(item_id: str, window_addr: str = "", window_class: str = "") -> None:
    if not cmd_copy(item_id):
        return

    time.sleep(0.09)
    try:
        if window_addr:
            subprocess.run(
                ["hyprctl", "dispatch", "focuswindow", f"address:{window_addr}"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )
            time.sleep(0.03)
        elif not window_class:
            try:
                out = subprocess.check_output(
                    ["hyprctl", "activewindow", "-j"], text=True, stderr=subprocess.DEVNULL
                )
                win_obj = json.loads(out)
                window_class = win_obj.get("class") or win_obj.get("initialClass") or ""
            except Exception:
                window_class = ""

        is_terminal = bool(
            re.search(r"kitty|terminal|alacritty|foot|xterm|wezterm", window_class, re.I)
        )
        if is_terminal:
            subprocess.run(
                ["wtype", "-M", "ctrl", "-M", "shift", "-k", "v", "-m", "shift", "-m", "ctrl"],
                check=False,
            )
        else:
            subprocess.run(["wtype", "-M", "ctrl", "-k", "v", "-m", "ctrl"], check=False)
    except Exception:
        pass


def cmd_delete(item_id: str) -> None:
    try:
        p1 = subprocess.Popen(["cliphist", "list"], stdout=subprocess.PIPE, text=True)
        p2 = subprocess.Popen(
            ["grep", "-m1", "-E", f"^{re.escape(item_id)}\t"],
            stdin=p1.stdout,
            stdout=subprocess.PIPE,
        )
        if p1.stdout:
            p1.stdout.close()
        subprocess.run(["cliphist", "delete"], stdin=p2.stdout, check=False)
        if p2.stdout:
            p2.stdout.close()
    except Exception as exc:
        print(f"Error deleting {item_id}: {exc}", file=sys.stderr)


def cmd_clear() -> None:
    try:
        subprocess.run(["cliphist", "wipe"], check=False)
        subprocess.run(["wl-copy", "--clear"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
        if TS_FILE.exists():
            TS_FILE.unlink()
        for thumb in THUMB_DIR.iterdir():
            try:
                thumb.unlink()
            except Exception:
                pass
    except Exception as exc:
        print(f"Error clearing: {exc}", file=sys.stderr)


def main() -> None:
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
            addr = sys.argv[3] if len(sys.argv) > 3 else ""
            wclass = sys.argv[4] if len(sys.argv) > 4 else ""
            cmd_paste(sys.argv[2], addr, wclass)
    elif action == "delete":
        if len(sys.argv) > 2:
            cmd_delete(sys.argv[2])
    elif action in ("clear", "wipe"):
        cmd_clear()
    else:
        cmd_list(action)


if __name__ == "__main__":
    main()
