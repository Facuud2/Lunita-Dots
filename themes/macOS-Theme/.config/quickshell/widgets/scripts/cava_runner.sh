#!/usr/bin/env bash
# 🌙 Lunita-Dots — Cava Spectrum Visualizer Runner for Media Widget
CONF="/tmp/cava_quickshell.conf"

if [ ! -f "$CONF" ]; then
cat << 'EOF' > "$CONF"
[general]
bars = 16
framerate = 30
autosens = 1

[input]
method = pipewire

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 100
bar_delimiter = 59
EOF
fi

exec cava -p "$CONF"
