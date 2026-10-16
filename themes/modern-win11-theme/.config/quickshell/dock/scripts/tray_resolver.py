#!/usr/bin/env python3
"""Resolve SystemTray icon references to valid QML Image URLs."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def main() -> None:
    # 1. Try resolving via centralized lunita-icon-resolver
    resolver_candidates = [
        Path.home() / ".local/bin/lunita-icon-resolver",
        Path(__file__).resolve().parents[6] / "core/.local/bin/lunita-icon-resolver",
    ]

    for candidate in resolver_candidates:
        if candidate.is_file():
            cmd = [sys.executable, str(candidate)] + sys.argv[1:]
            res = subprocess.run(cmd)
            sys.exit(res.returncode)

    # 2. Fallback direct pass-through
    if len(sys.argv) < 2:
        sys.exit(0)
    if sys.argv[1] == "--batch":
        for raw in sys.argv[2:]:
            if raw.startswith("image://qspixmap/") or raw.startswith("image://qsimage/") or raw.startswith("file://"):
                print(f"{raw}|{raw}")
    else:
        raw = sys.argv[1]
        if raw.startswith("image://qspixmap/") or raw.startswith("image://qsimage/") or raw.startswith("file://"):
            print(raw)


if __name__ == "__main__":
    main()
