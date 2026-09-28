#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — macOS Activity / System Resources Widget Provider
# ==============================================================================

import sys
import json
import time

try:
    import psutil
except ImportError:
    psutil = None

def get_stats():
    if psutil:
        try:
            # CPU
            cpu = int(round(psutil.cpu_percent(interval=None)))
            
            # RAM
            mem = psutil.virtual_memory()
            ram = int(round(mem.percent))
            ram_used_gb = round(mem.used / (1024 ** 3), 1)
            ram_total_gb = round(mem.total / (1024 ** 3), 1)

            # Disk (Root /)
            disk_info = psutil.disk_usage('/')
            disk = int(round(disk_info.percent))
            disk_used_gb = int(round(disk_info.used / (1024 ** 3)))
            disk_total_gb = int(round(disk_info.total / (1024 ** 3)))

            return {
                "cpu": cpu,
                "ram": ram,
                "ram_used": f"{ram_used_gb} GB",
                "ram_total": f"{ram_total_gb} GB",
                "disk": disk,
                "disk_used": f"{disk_used_gb} GB",
                "disk_total": f"{disk_total_gb} GB"
            }
        except Exception:
            pass

    # Fallback if psutil fails or is missing
    return {
        "cpu": 15,
        "ram": 45,
        "ram_used": "7.2 GB",
        "ram_total": "16.0 GB",
        "disk": 30,
        "disk_used": "150 GB",
        "disk_total": "500 GB"
    }

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "get"

    if action == "get":
        print(json.dumps(get_stats()))
    elif action == "watch":
        # Initial call to prime psutil cpu_percent
        if psutil:
            psutil.cpu_percent(interval=None)
            time.sleep(0.5)

        while True:
            stats = get_stats()
            print(json.dumps(stats), flush=True)
            time.sleep(2.0)

if __name__ == "__main__":
    main()
