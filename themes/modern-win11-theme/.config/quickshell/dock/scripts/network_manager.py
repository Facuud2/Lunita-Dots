#!/usr/bin/env python3
"""Network Manager helper for Modern-Win11-Theme Flyout (Ethernet & Wi-Fi via nmcli / ip)."""

import json
from pathlib import Path
import subprocess
import sys


def _get_iface_ipv4(dev: str) -> str:
    if not dev:
        return ""
    try:
        ip_out = subprocess.run(
            ["ip", "-br", "-4", "addr", "show", dev],
            capture_output=True,
            text=True,
            timeout=1,
            check=False,
        ).stdout.strip()
        parts = ip_out.split()
        if len(parts) >= 3:
            return parts[2].split("/")[0]
    except Exception:
        pass
    return ""


def get_network_info(rescan: bool = False) -> dict:
    result = {
        "ethernet": {
            "hasDevice": False,
            "enabled": False,
            "connected": False,
            "device": "",
            "name": "Ethernet",
            "ip": "",
        },
        "wifi": {
            "hasDevice": False,
            "enabled": False,
            "connected": False,
            "device": "",
            "name": "Wi-Fi",
            "ip": "",
            "signal": 0,
            "networks": [],
        },
        "activeType": "none",
        "activeName": "Desconectado",
        "activeIp": "",
        "connected": False,
    }

    try:
        # 1. Check Wi-Fi radio status
        wifi_radio = subprocess.run(
            ["nmcli", "radio", "wifi"],
            capture_output=True,
            text=True,
            timeout=2,
            check=False,
        ).stdout.strip().lower()
        result["wifi"]["enabled"] = wifi_radio in ("enabled", "habilitado")

        # 2. Get saved Wi-Fi connection names
        known_wifi: set[str] = set()
        conns_out = subprocess.run(
            ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"],
            capture_output=True,
            text=True,
            timeout=2,
            check=False,
        ).stdout
        for line in conns_out.strip().splitlines():
            if ":" in line:
                cname, ctype = line.rsplit(":", 1)
                if "wireless" in ctype or "wifi" in ctype:
                    known_wifi.add(cname.strip())

        # 3. Get device status from nmcli
        devs_out = subprocess.run(
            ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION,DEVICE", "device"],
            capture_output=True,
            text=True,
            timeout=2,
            check=False,
        ).stdout

        for line in devs_out.strip().splitlines():
            if not line:
                continue
            parts = line.split(":")
            if len(parts) < 4:
                continue
            dtype, dstate, dcon, ddev = parts[0], parts[1].lower(), parts[2], parts[3]

            if dtype == "ethernet":
                result["ethernet"]["hasDevice"] = True
                result["ethernet"]["device"] = ddev
                result["ethernet"]["enabled"] = dstate not in ("unavailable", "unmanaged", "no disponible")
                if dstate.startswith("connected") or dstate.startswith("conectado"):
                    result["ethernet"]["connected"] = True
                    result["ethernet"]["name"] = dcon if dcon else "Red cableada (Ethernet)"
                    result["ethernet"]["ip"] = _get_iface_ipv4(ddev)

            elif dtype == "wifi":
                result["wifi"]["hasDevice"] = True
                result["wifi"]["device"] = ddev
                if dstate.startswith("connected") or dstate.startswith("conectado"):
                    result["wifi"]["connected"] = True
                    result["wifi"]["name"] = dcon if dcon else "Wi-Fi"
                    result["wifi"]["ip"] = _get_iface_ipv4(ddev)

        # Fallback kernel check for Ethernet in case interface is unmanaged by NetworkManager
        if not result["ethernet"]["connected"]:
            sys_net = Path("/sys/class/net")
            if sys_net.is_dir():
                for iface_dir in sorted(sys_net.iterdir()):
                    iname = iface_dir.name
                    if iname.startswith(("en", "eth")):
                        result["ethernet"]["hasDevice"] = True
                        if not result["ethernet"]["device"]:
                            result["ethernet"]["device"] = iname
                        operstate_file = iface_dir / "operstate"
                        if operstate_file.is_file():
                            oper = operstate_file.read_text(encoding="utf-8", errors="ignore").strip().lower()
                            if oper == "up":
                                ip_addr = _get_iface_ipv4(iname)
                                if ip_addr:
                                    result["ethernet"]["enabled"] = True
                                    result["ethernet"]["connected"] = True
                                    result["ethernet"]["device"] = iname
                                    if result["ethernet"]["name"] == "Ethernet":
                                        result["ethernet"]["name"] = f"Ethernet ({iname})"
                                    result["ethernet"]["ip"] = ip_addr
                                    break

        # 4. Scan Wi-Fi networks when Wi-Fi is enabled
        if result["wifi"]["enabled"] and result["wifi"]["hasDevice"]:
            rescan_arg = "yes" if rescan else "no"
            wifi_scan = subprocess.run(
                [
                    "nmcli",
                    "-t",
                    "-f",
                    "IN-USE,SIGNAL,SECURITY,SSID",
                    "dev",
                    "wifi",
                    "list",
                    "--rescan",
                    rescan_arg,
                ],
                capture_output=True,
                text=True,
                timeout=6 if rescan else 3,
                check=False,
            ).stdout

            seen_ssids: set[str] = set()
            for line in wifi_scan.strip().splitlines():
                if not line:
                    continue
                # Format: IN-USE:SIGNAL:SECURITY:SSID (SSID may contain colons if escaped)
                wparts = line.split(":", 3)
                if len(wparts) < 4:
                    continue
                in_use = wparts[0].strip() == "*"
                try:
                    sig = int(wparts[1].strip())
                except ValueError:
                    sig = 50
                sec = wparts[2].strip()
                ssid = wparts[3].replace("\\:", ":").strip()

                if not ssid:
                    continue

                if in_use:
                    result["wifi"]["signal"] = sig
                    result["wifi"]["connected"] = True
                    result["wifi"]["name"] = ssid

                if ssid not in seen_ssids:
                    seen_ssids.add(ssid)
                    result["wifi"]["networks"].append({
                        "ssid": ssid,
                        "signal": sig,
                        "security": sec,
                        "secure": bool(sec and sec != "--"),
                        "active": in_use,
                        "known": in_use or (ssid in known_wifi),
                    })

            result["wifi"]["networks"].sort(
                key=lambda x: (1 if x["active"] else 0, 1 if x["known"] else 0, x["signal"]),
                reverse=True,
            )
            result["wifi"]["networks"] = result["wifi"]["networks"][:12]

        # 5. Overall primary status
        if result["ethernet"]["connected"]:
            result["connected"] = True
            result["activeType"] = "ethernet"
            result["activeName"] = result["ethernet"]["name"]
            result["activeIp"] = result["ethernet"]["ip"]
        elif result["wifi"]["connected"]:
            result["connected"] = True
            result["activeType"] = "wifi"
            result["activeName"] = result["wifi"]["name"]
            result["activeIp"] = result["wifi"]["ip"]
        else:
            result["connected"] = False
            result["activeType"] = "none"
            result["activeName"] = "Desconectado"
            result["activeIp"] = ""

    except Exception:
        pass

    return result


def main() -> None:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"

    if cmd == "status":
        print(json.dumps(get_network_info(rescan=False)))
    elif cmd == "scan":
        print(json.dumps(get_network_info(rescan=True)))
    elif cmd == "toggle_wifi":
        target = sys.argv[2] if len(sys.argv) > 2 else "toggle"
        if target == "toggle":
            cur = subprocess.run(
                ["nmcli", "radio", "wifi"],
                capture_output=True,
                text=True,
                timeout=2,
                check=False,
            ).stdout.strip().lower()
            target = "off" if cur in ("enabled", "habilitado") else "on"
        subprocess.run(["nmcli", "radio", "wifi", target], timeout=4, check=False)
        print(json.dumps(get_network_info(rescan=False)))
    elif cmd == "connect":
        ssid = sys.argv[2] if len(sys.argv) > 2 else ""
        password = sys.argv[3] if len(sys.argv) > 3 else ""
        if ssid:
            if password:
                subprocess.run(
                    ["nmcli", "dev", "wifi", "connect", ssid, "password", password],
                    capture_output=True,
                    text=True,
                    timeout=15,
                    check=False,
                )
            else:
                up_res = subprocess.run(
                    ["nmcli", "connection", "up", ssid],
                    capture_output=True,
                    text=True,
                    timeout=10,
                    check=False,
                )
                if up_res.returncode != 0:
                    subprocess.run(
                        ["nmcli", "dev", "wifi", "connect", ssid],
                        capture_output=True,
                        text=True,
                        timeout=12,
                        check=False,
                    )
        print(json.dumps(get_network_info(rescan=False)))
    elif cmd == "disconnect":
        target = sys.argv[2] if len(sys.argv) > 2 else ""
        if target:
            res = subprocess.run(
                ["nmcli", "connection", "down", target],
                capture_output=True,
                text=True,
                timeout=6,
                check=False,
            )
            if res.returncode != 0:
                subprocess.run(
                    ["nmcli", "dev", "disconnect", target],
                    capture_output=True,
                    text=True,
                    timeout=6,
                    check=False,
                )
        print(json.dumps(get_network_info(rescan=False)))


if __name__ == "__main__":
    main()
