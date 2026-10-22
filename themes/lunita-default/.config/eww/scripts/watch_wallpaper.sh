#!/usr/bin/env bash
# Script pasivo de consulta de wallpaper para Eww (sin bucles en segundo plano)
cat "${XDG_CACHE_HOME:-$HOME/.cache}/hyprquickpaper/current_wallpaper" 2>/dev/null | xargs basename 2>/dev/null || echo ""
