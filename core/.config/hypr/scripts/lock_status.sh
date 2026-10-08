#!/usr/bin/env bash
# ==============================================================================
# 📶 Lunita Hyprlock Status Helper (Top Right Bar: Network & Bluetooth)
# ==============================================================================

# 1. Network status
net_icon="󰖩"
if command -v nmcli >/dev/null 2>&1; then
    active_conn=$(nmcli -t -f TYPE,STATE dev 2>/dev/null | grep -E "wifi:connected|ethernet:connected" | head -n 1)
    if [[ "$active_conn" == *"ethernet"* ]]; then
        net_icon="󰈀"
    elif [[ "$active_conn" == *"wifi"* ]]; then
        net_icon="󰖩"
    else
        net_icon="󰖪"
    fi
fi

# 2. Bluetooth status
bt_icon="󰂲"
if command -v bluetoothctl >/dev/null 2>&1; then
    if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        if bluetoothctl info 2>/dev/null | grep -q "Device"; then
            bt_icon="󰂯"
        else
            bt_icon="󰂰"
        fi
    fi
fi

# 3. Battery status
bat_str=""
for bat in /sys/class/power_supply/BAT* /sys/class/power_supply/battery; do
    if [ -d "$bat" ] && [ -f "$bat/capacity" ]; then
        cap=$(cat "$bat/capacity" 2>/dev/null || echo "100")
        stat=$(cat "$bat/status" 2>/dev/null || echo "Discharging")
        icon=""
        if [ "$stat" = "Charging" ]; then
            icon="󰂄"
        elif [ "$cap" -le 15 ]; then
            icon=""
        elif [ "$cap" -le 40 ]; then
            icon=""
        elif [ "$cap" -le 70 ]; then
            icon=""
        elif [ "$cap" -le 90 ]; then
            icon=""
        fi
        bat_str="   $icon ${cap}%"
        break
    fi
done

echo "${net_icon}   ${bt_icon}${bat_str}"
