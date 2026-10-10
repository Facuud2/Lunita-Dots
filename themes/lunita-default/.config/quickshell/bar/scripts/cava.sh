#!/usr/bin/env bash
# 🌙 Lunita-Dots — Dynamic Island CAVA Runner
CONF="/tmp/cava_lunita_bar.conf"

cat << 'EOF' > "$CONF"
[general]
bars = 64
framerate = 60
autosens = 1
sensitivity = 180
overshoot = 20

[input]
method = pipewire
source = auto

[output]
channels = mono
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 100
bar_delimiter = 59

[smoothing]
monstercat = 1
waves = 0
noise_reduction = 15
EOF

exec cava -p "$CONF"
