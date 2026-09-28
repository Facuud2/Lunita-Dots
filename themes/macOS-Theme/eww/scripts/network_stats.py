#!/usr/bin/env python3
# ==============================================================================
# 🌙 Lunita-Dots — macOS Network Traffic & Connectivity Widget Provider
# ==============================================================================

import sys
import json
import time
import socket

try:
    import psutil
except ImportError:
    psutil = None

def get_primary_interface_and_ip():
    if not psutil:
        return "Ethernet", "eth0", "127.0.0.1", "UP"

    net_addrs = psutil.net_if_addrs()
    net_stats = psutil.net_if_stats()

    active_iface = None
    active_ip = "No IP"
    friendly_name = "Ethernet"
    is_up = False

    # Prefer non-virtual interfaces that are UP and have an IPv4 address
    candidates = []
    for iface, addrs in net_addrs.items():
        if iface.startswith(("lo", "docker", "veth", "br-", "virbr")):
            continue
        stat = net_stats.get(iface)
        up = stat.isup if stat else False
        ipv4_list = [a.address for a in addrs if a.family == socket.AF_INET]
        
        if up and ipv4_list:
            candidates.append((iface, ipv4_list[0], up))
        elif ipv4_list:
            candidates.append((iface, ipv4_list[0], up))

    if candidates:
        active_iface, active_ip, is_up = candidates[0]
    else:
        active_iface = "enp0"
        active_ip = "127.0.0.1"
        is_up = False

    if active_iface.startswith(("wl", "wlan", "wifi")):
        friendly_name = "Wi-Fi"
    elif active_iface.startswith(("en", "eth", "eno", "ens", "enp")):
        friendly_name = "Ethernet"
    elif active_iface.startswith(("tun", "tap", "wg", "tailscale")):
        friendly_name = "VPN"
    else:
        friendly_name = active_iface

    status_str = "UP" if is_up else "DOWN"
    return friendly_name, active_iface, active_ip, status_str

def format_rate(bytes_per_sec):
    kb = bytes_per_sec / 1024.0
    if kb < 1024:
        if kb < 1:
            val_str = "0"
        elif kb < 10:
            val_str = f"{kb:.1f}"
        else:
            val_str = f"{int(round(kb))}"
        return val_str, "KB/s"
    else:
        mb = kb / 1024.0
        val_str = f"{mb:.1f}" if mb < 100 else f"{int(round(mb))}"
        return val_str, "MB/s"

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "get"

    if action == "get":
        friendly_name, iface, ip, status = get_primary_interface_and_ip()
        payload = {
            "down_val": "0",
            "down_unit": "KB/s",
            "up_val": "0",
            "up_unit": "KB/s",
            "status": status,
            "status_class": "online" if status == "UP" else "offline",
            "interface": friendly_name,
            "iface_name": iface,
            "ip": ip
        }
        print(json.dumps(payload))
        return

    # Watch mode: continuous rate sampling
    last_time = time.time()
    last_io = psutil.net_io_counters() if psutil else None

    while True:
        time.sleep(1.5)
        now_time = time.time()
        dt = max(now_time - last_time, 0.1)

        friendly_name, iface, ip, status = get_primary_interface_and_ip()

        down_val, down_unit = "0", "KB/s"
        up_val, up_unit = "0", "KB/s"

        if psutil and last_io:
            current_io = psutil.net_io_counters()
            rx_rate = max(0, (current_io.bytes_recv - last_io.bytes_recv) / dt)
            tx_rate = max(0, (current_io.bytes_sent - last_io.bytes_sent) / dt)

            down_val, down_unit = format_rate(rx_rate)
            up_val, up_unit = format_rate(tx_rate)

            last_io = current_io
            last_time = now_time

        payload = {
            "down_val": down_val,
            "down_unit": down_unit,
            "up_val": up_val,
            "up_unit": up_unit,
            "status": status,
            "status_class": "online" if status == "UP" else "offline",
            "interface": friendly_name,
            "iface_name": iface,
            "ip": ip
        }
        print(json.dumps(payload), flush=True)

if __name__ == "__main__":
    main()
