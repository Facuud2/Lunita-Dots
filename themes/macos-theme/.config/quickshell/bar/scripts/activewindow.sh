#!/usr/bin/env bash
hyprctl activewindow -j 2>/dev/null | jq -c '{
  class: (.class // ""),
  initialClass: (.initialClass // ""),
  title: (.title // ""),
  initialTitle: (.initialTitle // ""),
  fullscreen: (.fullscreen // 0),
  floating: (.floating // false)
}' 2>/dev/null || echo '{}'
