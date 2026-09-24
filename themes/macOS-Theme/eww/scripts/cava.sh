#!/usr/bin/env bash

CONFIG="$HOME/.config/eww/cava.conf"

cava -p "$CONFIG" | sed -u     -e 's/0/▁/g'     -e 's/1/▂/g'     -e 's/2/▃/g'     -e 's/3/▄/g'     -e 's/4/▅/g'     -e 's/5/▆/g'     -e 's/6/▇/g'     -e 's/7/█/g'     -e 's/;//g'
