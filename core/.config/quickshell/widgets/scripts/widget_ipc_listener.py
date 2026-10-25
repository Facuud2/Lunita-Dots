#!/usr/bin/env python3
import os
import sys
import stat
import time
import signal
import subprocess

runtime_dir = os.environ.get("XDG_RUNTIME_DIR") or f"/tmp/lunita-{os.getuid()}"
os.makedirs(runtime_dir, exist_ok=True)
PIPE_PATH = os.path.join(runtime_dir, "lunita_widgets_ipc.pipe")

def terminate_other_listeners():
    my_pid = os.getpid()
    try:
        out = subprocess.check_output(["pgrep", "-u", str(os.getuid()), "-f", "widget_ipc_listener.py"], text=True)
        for line in out.strip().splitlines():
            pid = int(line.strip())
            if pid != my_pid:
                try:
                    os.kill(pid, signal.SIGTERM)
                except OSError:
                    pass
    except Exception:
        pass

def ensure_fifo():
    if os.path.exists(PIPE_PATH) and not stat.S_ISFIFO(os.stat(PIPE_PATH).st_mode):
        try:
            os.remove(PIPE_PATH)
        except Exception:
            pass
    if not os.path.exists(PIPE_PATH):
        try:
            os.mkfifo(PIPE_PATH, 0o600)
        except Exception:
            pass

def main():
    terminate_other_listeners()
    ensure_fifo()
    while True:
        if os.getppid() == 1:
            break
        try:
            ensure_fifo()
            # Open FIFO with O_RDWR so it never hits EOF when writers disconnect
            fd = os.open(PIPE_PATH, os.O_RDWR)
            with os.fdopen(fd, "r", encoding="utf-8") as fifo:
                for line in fifo:
                    if os.getppid() == 1:
                        sys.exit(0)
                    cmd = line.strip()
                    if cmd:
                        print(cmd, flush=True)
        except Exception:
            time.sleep(0.2)

if __name__ == "__main__":
    main()
