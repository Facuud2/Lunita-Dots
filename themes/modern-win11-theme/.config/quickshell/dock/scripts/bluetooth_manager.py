#!/usr/bin/env python3
"""Bluetooth Manager helper for Modern-Win11-Theme Flyout (via bluetoothctl)."""

import json
import subprocess
import sys


def _classify_device(name: str) -> str:
    low = name.lower()
    if any(k in low for k in ("head", "buds", "airpods", "audio", "sound", "speaker", "anc", "sony", "jbl", "bose")):
        return "audio"
    if any(k in low for k in ("key", "k380", "mx keys", "teclado")):
        return "keyboard"
    if any(k in low for k in ("mouse", "mx master", "ratón")):
        return "mouse"
    return "generic"


def get_bluetooth_info() -> dict:
    result = {
        "hasAdapter": False,
        "powered": False,
        "connectedDevice": "",
        "devices": [],
    }

    try:
        show_proc = subprocess.run(
            ["bluetoothctl", "show"],
            capture_output=True,
            text=True,
            timeout=2,
            check=False,
        )
        show_out = show_proc.stdout
        if "Controller " in show_out:
            result["hasAdapter"] = True
        result["powered"] = ("Powered: yes" in show_out) or ("PowerState: on" in show_out)

        if not result["hasAdapter"]:
            return result

        paired_out = subprocess.run(
            ["bluetoothctl", "devices", "Paired"],
            capture_output=True,
            text=True,
            timeout=2,
            check=False,
        ).stdout
        conn_out = subprocess.run(
            ["bluetoothctl", "devices", "Connected"],
            capture_output=True,
            text=True,
            timeout=2,
            check=False,
        ).stdout
        all_out = subprocess.run(
            ["bluetoothctl", "devices"],
            capture_output=True,
            text=True,
            timeout=2,
            check=False,
        ).stdout

        conn_macs: set[str] = set()
        for line in conn_out.strip().splitlines():
            parts = line.split(" ", 2)
            if len(parts) >= 2 and parts[0] == "Device":
                conn_macs.add(parts[1].strip())

        paired_macs: set[str] = set()
        devices_by_mac: dict[str, dict] = {}

        for line in paired_out.strip().splitlines():
            parts = line.split(" ", 2)
            if len(parts) >= 3 and parts[0] == "Device":
                mac = parts[1].strip()
                name = parts[2].strip()
                paired_macs.add(mac)
                is_conn = mac in conn_macs
                if is_conn and not result["connectedDevice"]:
                    result["connectedDevice"] = name
                devices_by_mac[mac] = {
                    "mac": mac,
                    "name": name,
                    "connected": is_conn,
                    "paired": True,
                    "type": _classify_device(name),
                }

        for line in all_out.strip().splitlines():
            parts = line.split(" ", 2)
            if len(parts) >= 3 and parts[0] == "Device":
                mac = parts[1].strip()
                name = parts[2].strip()
                if mac in devices_by_mac:
                    continue
                # Skip unnamed MAC-only entries
                if name.replace("-", ":") == mac:
                    continue
                is_conn = mac in conn_macs
                devices_by_mac[mac] = {
                    "mac": mac,
                    "name": name,
                    "connected": is_conn,
                    "paired": mac in paired_macs,
                    "type": _classify_device(name),
                }

        devices_list = list(devices_by_mac.values())
        devices_list.sort(
            key=lambda d: (1 if d["connected"] else 0, 1 if d["paired"] else 0, d["name"].lower()),
            reverse=True,
        )
        result["devices"] = devices_list[:12]

    except Exception:
        pass

    return result


def main() -> None:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"

    if cmd == "status":
        print(json.dumps(get_bluetooth_info()))
    elif cmd == "power":
        target = sys.argv[2] if len(sys.argv) > 2 else "toggle"
        if target == "toggle":
            info = get_bluetooth_info()
            target = "off" if info["powered"] else "on"
        if target == "on":
            subprocess.run(["rfkill", "unblock", "bluetooth"], capture_output=True, timeout=2, check=False)
        subprocess.run(["bluetoothctl", "power", target], capture_output=True, timeout=3, check=False)
        print(json.dumps(get_bluetooth_info()))
    elif cmd == "scan":
        subprocess.run(
            ["bluetoothctl", "--timeout", "4", "scan", "on"],
            capture_output=True,
            text=True,
            timeout=6,
            check=False,
        )
        print(json.dumps(get_bluetooth_info()))
    elif cmd == "connect":
        mac = sys.argv[2] if len(sys.argv) > 2 else ""
        if mac:
            subprocess.run(["bluetoothctl", "trust", mac], capture_output=True, timeout=3, check=False)
            res = subprocess.run(["bluetoothctl", "connect", mac], capture_output=True, timeout=8, check=False)
            if res.returncode != 0:
                subprocess.run(["bluetoothctl", "pair", mac], capture_output=True, timeout=8, check=False)
                subprocess.run(["bluetoothctl", "connect", mac], capture_output=True, timeout=8, check=False)
        print(json.dumps(get_bluetooth_info()))
    elif cmd == "disconnect":
        mac = sys.argv[2] if len(sys.argv) > 2 else ""
        if mac:
            subprocess.run(["bluetoothctl", "disconnect", mac], capture_output=True, timeout=6, check=False)
        print(json.dumps(get_bluetooth_info()))


if __name__ == "__main__":
    main()
