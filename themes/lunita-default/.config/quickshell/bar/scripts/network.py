#!/usr/bin/env python3
import subprocess, json

def get_network_info():
    result = {
        "ethernet": {
            "hasDevice": False,
            "enabled": False,
            "connected": False,
            "device": "",
            "name": "Ethernet",
            "ip": ""
        },
        "wifi": {
            "hasDevice": False,
            "enabled": False,
            "connected": False,
            "device": "",
            "name": "Wi-Fi",
            "ip": "",
            "signal": 0,
            "networks": []
        },
        "savedNets": [],
        "nearbyNets": [],
        "activeType": "none",
        "activeName": "Desconectado",
        "activeIp": "",
        "connected": False
    }

    try:
        # 1. Check wifi radio status
        wifi_radio = subprocess.run(["nmcli", "radio", "wifi"], capture_output=True, text=True, timeout=1).stdout.strip()
        result["wifi"]["enabled"] = (wifi_radio == "enabled")

        # 2. Get device status
        devs_out = subprocess.run(["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION,DEVICE", "device"], capture_output=True, text=True, timeout=2).stdout
        
        for line in devs_out.strip().split("\n"):
            if not line:
                continue
            parts = line.split(":")
            if len(parts) >= 4:
                dtype, dstate, dcon, ddev = parts[0], parts[1], parts[2], parts[3]
                
                # Check Ethernet
                if dtype == "ethernet":
                    result["ethernet"]["hasDevice"] = True
                    result["ethernet"]["device"] = ddev
                    result["ethernet"]["enabled"] = (dstate != "unavailable" and dstate != "unmanaged")
                    if dstate == "connected" or dstate == "conectado":
                        result["ethernet"]["connected"] = True
                        result["ethernet"]["name"] = dcon if dcon else "Conexión cableada"
                        # Get IP
                        ip_cmd = subprocess.run(["ip", "-br", "addr", "show", ddev], capture_output=True, text=True, timeout=1).stdout
                        ip_parts = ip_cmd.strip().split()
                        if len(ip_parts) >= 3:
                            result["ethernet"]["ip"] = ip_parts[2].split('/')[0]

                # Check Wi-Fi
                elif dtype == "wifi":
                    result["wifi"]["hasDevice"] = True
                    result["wifi"]["device"] = ddev
                    if dstate == "connected" or dstate == "conectado":
                        result["wifi"]["connected"] = True
                        result["wifi"]["name"] = dcon if dcon else "Wi-Fi"
                        # Get IP
                        ip_cmd = subprocess.run(["ip", "-br", "addr", "show", ddev], capture_output=True, text=True, timeout=1).stdout
                        ip_parts = ip_cmd.strip().split()
                        if len(ip_parts) >= 3:
                            result["wifi"]["ip"] = ip_parts[2].split('/')[0]

        # 3. Get saved connections
        saved_cmd = subprocess.run(["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"], capture_output=True, text=True, timeout=2).stdout
        saved_list = []
        for line in saved_cmd.strip().split("\n"):
            if not line:
                continue
            parts = line.split(":")
            if len(parts) >= 2 and ("wireless" in parts[1] or "wifi" in parts[1] or "802-11" in parts[1]):
                con_name = parts[0].strip()
                if con_name:
                    saved_list.append({
                        "name": con_name,
                        "connected": (result["wifi"]["connected"] and result["wifi"]["name"] == con_name)
                    })
        result["savedNets"] = saved_list

        # 4. If Wi-Fi is enabled, scan available networks
        if result["wifi"]["enabled"] and result["wifi"]["hasDevice"]:
            wifi_scan = subprocess.run(["nmcli", "-t", "-f", "IN-USE,SIGNAL,SSID,SECURITY", "dev", "wifi"], capture_output=True, text=True, timeout=3).stdout
            seen_ssids = set()
            nearby_list = []
            for line in wifi_scan.strip().split("\n"):
                if not line:
                    continue
                wparts = line.split(":")
                if len(wparts) >= 4:
                    in_use = (wparts[0].strip() == "*")
                    try:
                        sig = int(wparts[1].strip())
                    except:
                        sig = 50
                    ssid = wparts[2].strip()
                    sec = wparts[3].strip()
                    
                    if in_use:
                        result["wifi"]["signal"] = sig
                        if not result["wifi"]["name"] or result["wifi"]["name"] == "Wi-Fi":
                            result["wifi"]["name"] = ssid
                    
                    if ssid and ssid not in seen_ssids:
                        seen_ssids.add(ssid)
                        sec_bool = bool(sec and sec != "--")
                        nearby_list.append({
                            "name": ssid,
                            "signal": sig,
                            "secure": sec_bool,
                            "connected": in_use
                        })
                        result["wifi"]["networks"].append({
                            "ssid": ssid,
                            "signal": sig,
                            "security": sec,
                            "active": in_use
                        })

            # Sort networks: active first, then highest signal
            nearby_list.sort(key=lambda x: (1 if x["connected"] else 0, x["signal"]), reverse=True)
            result["nearbyNets"] = nearby_list

        # 5. Determine overall primary active connection
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

    except Exception as e:
        pass

    return result

if __name__ == "__main__":
    print(json.dumps(get_network_info()))
