#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — System Resources Provider for Quickshell Widgets
# Captures CPU, RAM (with GB counters), GPU (AMD sysfs/Nvidia) and Disk metrics
# ==============================================================================

import os
import glob
import json
import psutil

def get_gpu_metrics():
    # 1. AMD GPU via sysfs
    busy_paths = glob.glob('/sys/class/drm/card*/device/gpu_busy_percent')
    vram_used_paths = glob.glob('/sys/class/drm/card*/device/mem_info_vram_used')
    vram_total_paths = glob.glob('/sys/class/drm/card*/device/mem_info_vram_total')
    
    if busy_paths:
        try:
            with open(busy_paths[0], 'r') as f:
                gpu_busy = int(f.read().strip())
            vu, vt = 0, 0
            if vram_used_paths:
                with open(vram_used_paths[0], 'r') as f:
                    vu = int(f.read().strip())
            if vram_total_paths:
                with open(vram_total_paths[0], 'r') as f:
                    vt = int(f.read().strip())
            vram_pct = int((vu / vt) * 100) if vt > 0 else 0
            return {
                "gpu": gpu_busy,
                "vram_pct": vram_pct,
                "vram_used": f"{vu / (1024**3):.1f} GB",
                "vram_total": f"{vt / (1024**3):.1f} GB"
            }
        except Exception:
            pass

    # 2. Nvidia GPU fallback
    try:
        import subprocess
        out = subprocess.check_output(
            ["nvidia-smi", "--query-gpu=utilization.gpu,memory.used,memory.total", "--format=csv,noheader,nounits"],
            stderr=subprocess.DEVNULL, timeout=1
        ).decode().strip()
        parts = [p.strip() for p in out.split(',')]
        if len(parts) >= 3:
            gpu_u = int(parts[0])
            mem_u = float(parts[1]) / 1024.0
            mem_t = float(parts[2]) / 1024.0
            return {
                "gpu": gpu_u,
                "vram_pct": int((mem_u / mem_t) * 100) if mem_t > 0 else 0,
                "vram_used": f"{mem_u:.1f} GB",
                "vram_total": f"{mem_t:.1f} GB"
            }
    except Exception:
        pass

    return {
        "gpu": 0,
        "vram_pct": 0,
        "vram_used": "0.0 GB",
        "vram_total": "0.0 GB"
    }

def main():
    try:
        v = psutil.virtual_memory()
        d = psutil.disk_usage('/')
        gpu_info = get_gpu_metrics()

        payload = {
            "cpu": int(psutil.cpu_percent(interval=None)),
            "ram": int(v.percent),
            "ram_used": f"{v.used / (1024**3):.1f} GB",
            "ram_total": f"{v.total / (1024**3):.1f} GB",
            "gpu": gpu_info["gpu"],
            "vram_pct": gpu_info["vram_pct"],
            "vram_used": gpu_info["vram_used"],
            "vram_total": gpu_info["vram_total"],
            "disk": int(d.percent),
            "disk_used": f"{d.used / (1024**3):.0f} GB",
            "disk_total": f"{d.total / (1024**3):.0f} GB"
        }
        print(json.dumps(payload))
    except Exception as e:
        print(json.dumps({
            "cpu": 0, "ram": 0, "ram_used": "0 GB", "ram_total": "0 GB",
            "gpu": 0, "vram_pct": 0, "vram_used": "0 GB", "vram_total": "0 GB",
            "disk": 0, "disk_used": "0 GB", "disk_total": "0 GB"
        }))

if __name__ == "__main__":
    main()
