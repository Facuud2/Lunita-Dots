#!/usr/bin/env bash
# 🌙 Lunita-Dots — Active Window Inspector for Modern Win 11 Theme V2
hyprctl activewindow -j 2>/dev/null | jq -c '{
  class: (.class // ""),
  initialClass: (.initialClass // ""),
  title: (.title // ""),
  initialTitle: (.initialTitle // ""),
  fullscreen: (.fullscreen // 0),
  floating: (.floating // false)
}' 2>/dev/null || echo '{"fullscreen": 0, "title": "", "class": ""}'
