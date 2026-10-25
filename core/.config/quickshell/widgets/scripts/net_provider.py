#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — Network Metrics Provider for Quickshell Widgets
# Captures download/upload speeds, IP, active interface and raw KB/s for sparkline
# ==============================================================================

import json
import os
from pathlib import Path
import socket
import time


def get_default_interface_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()

    iface_name = "Ethernet"
    route_file = Path("/proc/net/route")
    if route_file.exists():
        try:
            with open(route_file, "r", encoding="utf-8") as f:
                for line in f.readlines()[1:]:
                    parts = line.strip().split()
                    if len(parts) >= 2 and parts[1] == "00000000":
                        raw_iface = parts[0]
                        if raw_iface.startswith("wl"):
                            iface_name = "Wi-Fi"
                        elif raw_iface.startswith(("en", "eth")):
                            iface_name = "Ethernet"
                        else:
                            iface_name = raw_iface
                        break
        except Exception:
            pass

    return ip, iface_name


def read_net_bytes():
    rx, tx = 0, 0
    dev_file = Path("/proc/net/dev")
    if not dev_file.exists():
        return rx, tx

    try:
        with open(dev_file, "r", encoding="utf-8") as f:
            for line in f.readlines()[2:]:
                parts = line.split(":")
                if len(parts) == 2:
                    iface = parts[0].strip()
                    if iface == "lo":
                        continue
                    vals = parts[1].split()
                    if len(vals) >= 9:
                        rx += int(vals[0])
                        tx += int(vals[8])
    except Exception:
        pass
    return rx, tx


def main():
    try:
        cache_file = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "lunita_net_last"
        now = time.time()
        rx2, tx2 = read_net_bytes()

        db = 0.0
        ub = 0.0

        if cache_file.exists():
            try:
                content = cache_file.read_text(encoding="utf-8").strip().split()
                t_prev = float(content[0])
                rx1 = int(content[1])
                tx1 = int(content[2])
                dt = now - t_prev
                if dt > 0.05:
                    db = max(0.0, (rx2 - rx1) / dt)
                    ub = max(0.0, (tx2 - tx1) / dt)
            except Exception:
                pass

        if db == 0.0 and ub == 0.0 and not cache_file.exists():
            # First run: quick sample
            time.sleep(0.2)
            rx3, tx3 = read_net_bytes()
            db = max(0.0, (rx3 - rx2) / 0.2)
            ub = max(0.0, (tx3 - tx2) / 0.2)
            rx2, tx2 = rx3, tx3
            now = time.time()

        try:
            cache_file.write_text(f"{now} {rx2} {tx2}\n", encoding="utf-8")
        except Exception:
            pass

        down_kb = db / 1024.0
        up_kb = ub / 1024.0

        if db >= 1024 * 1024:
            dv, du = f"{db / (1024**2):.1f}", "MB/s"
        else:
            dv, du = f"{down_kb:.0f}", "KB/s"

        if ub >= 1024 * 1024:
            uv, uu = f"{ub / (1024**2):.1f}", "MB/s"
        else:
            uv, uu = f"{up_kb:.0f}", "KB/s"

        ip, iface = get_default_interface_ip()

        payload = {
            "down_val": dv,
            "down_unit": du,
            "up_val": uv,
            "up_unit": uu,
            "down_kb": round(down_kb, 1),
            "up_kb": round(up_kb, 1),
            "total_kb": round(down_kb + up_kb, 1),
            "ip": ip,
            "interface": iface,
            "status": "UP",
        }
        print(json.dumps(payload))
    except Exception:
        print(json.dumps({
            "down_val": "0", "down_unit": "KB/s",
            "up_val": "0", "up_unit": "KB/s",
            "down_kb": 0, "up_kb": 0, "total_kb": 0,
            "ip": "127.0.0.1", "interface": "Ethernet", "status": "UP"
        }))


if __name__ == "__main__":
    main()
