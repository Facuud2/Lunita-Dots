#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — Network Metrics Provider for Quickshell Widgets
# Captures download/upload speeds, IP, active interface and raw KB/s for sparkline
# ==============================================================================

import time
import json
import socket
import psutil

def get_default_interface_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'
    finally:
        s.close()
    
    # Detect interface name associated with this IP
    iface_name = "Ethernet"
    try:
        for iface, addrs in psutil.net_if_addrs().items():
            for addr in addrs:
                if addr.family == socket.AF_INET and addr.address == ip:
                    if iface.startswith("wl"):
                        iface_name = "Wi-Fi"
                    elif iface.startswith(("en", "eth")):
                        iface_name = "Ethernet"
                    else:
                        iface_name = iface
                    break
    except Exception:
        pass

    return ip, iface_name

def main():
    try:
        t1 = psutil.net_io_counters()
        time.sleep(0.25)
        t2 = psutil.net_io_counters()

        db = (t2.bytes_recv - t1.bytes_recv) / 0.25
        ub = (t2.bytes_sent - t1.bytes_sent) / 0.25

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
            "status": "UP"
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
