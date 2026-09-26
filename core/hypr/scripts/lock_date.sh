#!/usr/bin/env bash
# ==============================================================================
# 📅 Lunita Hyprlock Date Formatter
# Outputs date in sleek lowercase macOS style (e.g. "vie 15 may" or "vie 26 sep")
# ==============================================================================

if locale -a 2>/dev/null | grep -qi "es_"; then
    loc=$(locale -a 2>/dev/null | grep -i "es_" | head -n 1)
    LC_TIME="$loc" date +"%a %-d %b" 2>/dev/null | tr '[:upper:]' '[:lower:]' | sed 's/\.//g'
else
    LC_TIME=C date +"%a %-d %b" 2>/dev/null | tr '[:upper:]' '[:lower:]'
fi
