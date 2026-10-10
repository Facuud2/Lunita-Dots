#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys

def get_players():
    try:
        out = subprocess.check_output(["playerctl", "-l"], stderr=subprocess.DEVNULL).decode().strip().split("\n")
        return [p.strip() for p in out if p.strip()]
    except Exception:
        return []

def get_player_status(player):
    try:
        return subprocess.check_output(["playerctl", "-p", player, "status"], stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        return "Stopped"

def get_active_player(players):
    if not players:
        return None
    # Prefer currently playing player
    for p in players:
        if get_player_status(p) == "Playing":
            return p
    # Otherwise fallback to first
    return players[0]

def query_mpris():
    players = get_players()
    player = get_active_player(players)

    data = {
        "active": False,
        "player": "",
        "playing": False,
        "title": "",
        "artist": "",
        "artUrl": "",
        "position": 0.0,
        "length": 0.0,
    }

    if not player:
        print(json.dumps(data), flush=True)
        return

    data["active"] = True
    data["player"] = player

    # 1. Try formatted playerctl metadata
    try:
        cmd = ["playerctl", "-p", player, "metadata", "--format", "{{status}}\t{{position}}\t{{mpris:length}}\t{{xesam:title}}\t{{xesam:artist}}\t{{mpris:artUrl}}"]
        meta = subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode().strip().split("\t")
        if len(meta) >= 6:
            data["playing"] = (meta[0] == "Playing")
            if meta[1] and meta[1].strip():
                try:
                    data["position"] = float(meta[1].strip()) / 1000000.0
                except Exception:
                    pass
            if meta[2] and meta[2].strip():
                try:
                    data["length"] = float(meta[2].strip()) / 1000000.0
                except Exception:
                    pass
            data["title"] = meta[3].strip()
            data["artist"] = meta[4].strip()
            data["artUrl"] = meta[5].strip()
    except Exception:
        pass

    # 2. If status or title is missing, fallback to simple playerctl
    if not data["title"]:
        try:
            data["title"] = subprocess.check_output(["playerctl", "-p", player, "metadata", "xesam:title"], stderr=subprocess.DEVNULL).decode().strip()
        except Exception:
            pass
    if not data["artist"]:
        try:
            data["artist"] = subprocess.check_output(["playerctl", "-p", player, "metadata", "xesam:artist"], stderr=subprocess.DEVNULL).decode().strip()
        except Exception:
            pass
    if not data["artUrl"]:
        try:
            data["artUrl"] = subprocess.check_output(["playerctl", "-p", player, "metadata", "mpris:artUrl"], stderr=subprocess.DEVNULL).decode().strip()
        except Exception:
            pass

    # 3. If position is 0, query playerctl position directly (returns seconds)
    if data["position"] <= 0.001:
        try:
            pos_str = subprocess.check_output(["playerctl", "-p", player, "position"], stderr=subprocess.DEVNULL).decode().strip()
            pos_val = float(pos_str)
            data["position"] = pos_val
        except Exception:
            pass

    # 4. If length is 0, query playerctl metadata mpris:length directly
    if data["length"] <= 0.0:
        try:
            len_str = subprocess.check_output(["playerctl", "-p", player, "metadata", "mpris:length"], stderr=subprocess.DEVNULL).decode().strip()
            data["length"] = float(len_str) / 1000000.0
        except Exception:
            pass

    # 5. If length or position is still 0/missing (e.g. Firefox/Zen bug), query DBus GetAll
    if data["length"] <= 0.0 or data["position"] <= 0.001:
        try:
            dest = f"org.mpris.MediaPlayer2.{player}"
            dbus_cmd = [
                "gdbus", "call", "--session", "--dest", dest,
                "--object-path", "/org/mpris/MediaPlayer2",
                "--method", "org.freedesktop.DBus.Properties.GetAll",
                "org.mpris.MediaPlayer2.Player"
            ]
            raw = subprocess.check_output(dbus_cmd, stderr=subprocess.DEVNULL).decode()
            if data["length"] <= 0.0:
                len_m = re.search(r"'mpris:length':\s*<(?:int64|uint64)\s+(\d+)>", raw)
                if len_m:
                    data["length"] = float(len_m.group(1)) / 1000000.0
            if data["position"] <= 0.001:
                pos_m = re.search(r"'Position':\s*<(?:int64|uint64)\s+(\d+)>", raw)
                if pos_m:
                    data["position"] = float(pos_m.group(1)) / 1000000.0
        except Exception:
            pass

    print(json.dumps(data), flush=True)

if __name__ == "__main__":
    query_mpris()
