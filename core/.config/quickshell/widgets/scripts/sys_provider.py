#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — System Resources Provider for Quickshell Widgets
# Captures CPU, RAM (with GB counters), GPU (AMD sysfs/Nvidia) and Disk metrics
# ==============================================================================

import glob
import json
import os
import time
from pathlib import Path


def get_cpu_percent() -> int:
    stat_file = Path("/proc/stat")
    if not stat_file.exists():
        return 0

    def read_stat():
        with open("/proc/stat", "r", encoding="utf-8") as f:
            fields = [float(x) for x in f.readline().split()[1:]]
        idle = fields[3] + (fields[4] if len(fields) > 4 else 0.0)
        total = sum(fields)
        return total, idle

    cache_file = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "lunita_cpu_last"
    t2, i2 = read_stat()

    if cache_file.exists():
        try:
            content = cache_file.read_text(encoding="utf-8").strip().split()
            t1, i1 = float(content[0]), float(content[1])
            diff_t = t2 - t1
            diff_i = i2 - i1
            if diff_t > 0:
                pct = int((1.0 - (diff_i / diff_t)) * 100)
                cache_file.write_text(f"{t2} {i2}\n", encoding="utf-8")
                return max(0, min(100, pct))
        except Exception:
            pass

    # Fallback sampling on first run
    time.sleep(0.05)
    t3, i3 = read_stat()
    diff_t = t3 - t2
    diff_i = i3 - i2
    pct = int((1.0 - (diff_i / diff_t)) * 100) if diff_t > 0 else 0
    try:
        cache_file.write_text(f"{t3} {i3}\n", encoding="utf-8")
    except Exception:
        pass
    return max(0, min(100, pct))


def get_ram_metrics():
    meminfo_file = Path("/proc/meminfo")
    if not meminfo_file.exists():
        return 0, "0.0 GB", "0.0 GB"

    try:
        data = {}
        with open(meminfo_file, "r", encoding="utf-8") as f:
            for line in f:
                if ":" in line:
                    k, v = line.split(":", 1)
                    data[k.strip()] = int(v.strip().split()[0])

        total_kb = data.get("MemTotal", 1)
        avail_kb = data.get("MemAvailable", data.get("MemFree", 0))
        used_kb = max(0, total_kb - avail_kb)

        pct = int((used_kb / total_kb) * 100)
        used_gb = f"{used_kb * 1024 / (1024**3):.1f} GB"
        total_gb = f"{total_kb * 1024 / (1024**3):.1f} GB"
        return pct, used_gb, total_gb
    except Exception:
        return 0, "0.0 GB", "0.0 GB"


def get_disk_metrics():
    try:
        st = os.statvfs("/")
        total = st.f_blocks * st.f_frsize
        free = st.f_bavail * st.f_frsize
        used = max(0, total - free)

        pct = int((used / total) * 100) if total > 0 else 0
        used_gb = f"{used / (1024**3):.0f} GB"
        total_gb = f"{total / (1024**3):.0f} GB"
        return pct, used_gb, total_gb
    except Exception:
        return 0, "0 GB", "0 GB"


def get_gpu_metrics():
    # 1. AMD GPU via sysfs
    busy_paths = glob.glob("/sys/class/drm/card*/device/gpu_busy_percent")
    vram_used_paths = glob.glob("/sys/class/drm/card*/device/mem_info_vram_used")
    vram_total_paths = glob.glob("/sys/class/drm/card*/device/mem_info_vram_total")

    if busy_paths:
        try:
            with open(busy_paths[0], "r") as f:
                gpu_busy = int(f.read().strip())
            vu, vt = 0, 0
            if vram_used_paths:
                with open(vram_used_paths[0], "r") as f:
                    vu = int(f.read().strip())
            if vram_total_paths:
                with open(vram_total_paths[0], "r") as f:
                    vt = int(f.read().strip())
            vram_pct = int((vu / vt) * 100) if vt > 0 else 0
            return {
                "gpu": gpu_busy,
                "vram_pct": vram_pct,
                "vram_used": f"{vu / (1024**3):.1f} GB",
                "vram_total": f"{vt / (1024**3):.1f} GB",
            }
        except Exception:
            pass

    # 2. Nvidia GPU fallback
    try:
        import subprocess

        out = subprocess.check_output(
            ["nvidia-smi", "--query-gpu=utilization.gpu,memory.used,memory.total", "--format=csv,noheader,nounits"],
            stderr=subprocess.DEVNULL,
            timeout=1,
        ).decode().strip()
        parts = [p.strip() for p in out.split(",")]
        if len(parts) >= 3:
            gpu_u = int(parts[0])
            mem_u = float(parts[1]) / 1024.0
            mem_t = float(parts[2]) / 1024.0
            return {
                "gpu": gpu_u,
                "vram_pct": int((mem_u / mem_t) * 100) if mem_t > 0 else 0,
                "vram_used": f"{mem_u:.1f} GB",
                "vram_total": f"{mem_t:.1f} GB",
            }
    except Exception:
        pass

    return {
        "gpu": 0,
        "vram_pct": 0,
        "vram_used": "0.0 GB",
        "vram_total": "0.0 GB",
    }


def main():
    try:
        cpu_val = get_cpu_percent()
        ram_pct, ram_used, ram_total = get_ram_metrics()
        disk_pct, disk_used, disk_total = get_disk_metrics()
        gpu_info = get_gpu_metrics()

        payload = {
            "cpu": cpu_val,
            "ram": ram_pct,
            "ram_used": ram_used,
            "ram_total": ram_total,
            "gpu": gpu_info["gpu"],
            "vram_pct": gpu_info["vram_pct"],
            "vram_used": gpu_info["vram_used"],
            "vram_total": gpu_info["vram_total"],
            "disk": disk_pct,
            "disk_used": disk_used,
            "disk_total": disk_total,
        }
        print(json.dumps(payload))
    except Exception:
        print(json.dumps({
            "cpu": 0, "ram": 0, "ram_used": "0 GB", "ram_total": "0 GB",
            "gpu": 0, "vram_pct": 0, "vram_used": "0 GB", "vram_total": "0 GB",
            "disk": 0, "disk_used": "0 GB", "disk_total": "0 GB"
        }))


if __name__ == "__main__":
    main()
