#!/usr/bin/env python3
import json, glob

def get_metrics():
    # 1. CPU Raw counters
    cpu_stat = []
    try:
        with open("/proc/stat") as f:
            cpu_stat = f.readline().split()[1:]
    except Exception:
        pass

    # 2. RAM Percentage
    ram = 0
    try:
        with open("/proc/meminfo") as f:
            mem_lines = f.readlines()
        tot = int([l for l in mem_lines if l.startswith("MemTotal:")][0].split()[1])
        avail = int([l for l in mem_lines if l.startswith("MemAvailable:")][0].split()[1])
        ram = round((tot - avail) / tot * 100)
    except Exception:
        pass

    # 3. CPU Temp
    cpu_temp = 0
    for hw in glob.glob("/sys/class/hwmon/hwmon*"):
        try:
            with open(hw + "/name") as f:
                n = f.read().strip()
            if n in ["k10temp", "coretemp", "zenpower"]:
                with open(hw + "/temp1_input") as f:
                    cpu_temp = round(int(f.read().strip()) / 1000)
                break
        except Exception:
            pass

    # 4. GPU Usage & Temp (AMD / Intel / Nvidia)
    gpu_busy = 0
    gpu_temp = 0
    gpu_avail = False

    # Check AMD / Intel DRM sysfs
    for card in glob.glob("/sys/class/drm/card*/device/gpu_busy_percent"):
        try:
            with open(card) as f:
                gpu_busy = int(f.read().strip())
                gpu_avail = True
                break
        except Exception:
            pass

    for hw in glob.glob("/sys/class/hwmon/hwmon*"):
        try:
            with open(hw + "/name") as f:
                n = f.read().strip()
            if n in ["amdgpu", "nouveau"]:
                with open(hw + "/temp1_input") as f:
                    gpu_temp = round(int(f.read().strip()) / 1000)
                gpu_avail = True
                break
        except Exception:
            pass

    # Fallback to nvidia-smi if no DRM found
    if not gpu_avail:
        try:
            import subprocess
            out = subprocess.check_output(
                ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"],
                timeout=1, text=True
            ).strip()
            parts = [int(p.strip()) for p in out.split(",")]
            gpu_busy = parts[0]
            gpu_temp = parts[1]
            gpu_avail = True
        except Exception:
            pass

    return {
        "cpu_raw": cpu_stat,
        "ram": ram,
        "cpu_temp": cpu_temp,
        "gpu": gpu_busy,
        "gpu_temp": gpu_temp,
        "gpu_avail": gpu_avail
    }

if __name__ == "__main__":
    print(json.dumps(get_metrics()))
