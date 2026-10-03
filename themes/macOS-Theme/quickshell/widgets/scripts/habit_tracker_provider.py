#!/usr/bin/env python3
import sys
import os

script_dir = os.path.dirname(os.path.abspath(__file__))
health_script = os.path.join(script_dir, "health_tracker_provider.py")

if os.path.exists(health_script):
    os.execv(sys.executable, [sys.executable, health_script] + sys.argv[1:])
