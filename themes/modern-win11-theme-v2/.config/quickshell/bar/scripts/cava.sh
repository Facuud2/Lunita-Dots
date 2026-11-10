#!/usr/bin/env bash
# 🌙 Lunita-Dots — Dynamic Island CAVA Runner for Modern Win 11 Theme
CONF="/tmp/cava_win11_notch.conf"

cat << 'EOF' > "$CONF"
[general]
bars = 36
framerate = 35
autosens = 1
overshoot = 20

[input]
method = pipewire

[output]
channels = mono
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 100
bar_delimiter = 59
EOF

exec cava -p "$CONF"
