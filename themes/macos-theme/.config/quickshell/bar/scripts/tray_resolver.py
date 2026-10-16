#!/usr/bin/env python3
"""SystemTray Icon Resolver for Quickshell Status Bar."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


def main() -> None:
    resolver_candidates = [
        Path.home() / ".local/bin/lunita-icon-resolver",
        Path(__file__).resolve().parents[6] / "core/.local/bin/lunita-icon-resolver",
    ]

    for candidate in resolver_candidates:
        if candidate.is_file():
            cmd = [sys.executable, str(candidate), "--json"] + sys.argv[1:]
            res = subprocess.run(cmd)
            sys.exit(res.returncode)

    res: dict[str, str] = {}
    for ic in sys.argv[1:]:
        if ic.startswith("image://qspixmap/") or ic.startswith("image://qsimage/") or ic.startswith("file://"):
            res[ic] = ic
    print(json.dumps(res))


if __name__ == "__main__":
    main()
