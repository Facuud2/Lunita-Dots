#!/usr/bin/env python3
import os
import sys
import time

PIPE_PATH = "/tmp/lunita_widgets_ipc.pipe"

def ensure_fifo():
    if os.path.exists(PIPE_PATH) and not os.path.isabs(PIPE_PATH):
        try:
            os.remove(PIPE_PATH)
        except Exception:
            pass
    if not os.path.exists(PIPE_PATH):
        try:
            os.mkfifo(PIPE_PATH, 0o666)
        except Exception:
            pass

def main():
    ensure_fifo()
    while True:
        try:
            ensure_fifo()
            # Open FIFO for reading; this blocks until a writer connects
            with open(PIPE_PATH, "r") as fifo:
                for line in fifo:
                    cmd = line.strip()
                    if cmd:
                        print(cmd, flush=True)
        except Exception:
            time.sleep(0.2)

if __name__ == "__main__":
    main()
