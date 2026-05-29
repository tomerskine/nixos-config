#!/usr/bin/env python3
import os
import socket
import subprocess

socket_path = f"{os.environ['XDG_RUNTIME_DIR']}/hypr/{os.environ['HYPRLAND_INSTANCE_SIGNATURE']}/.socket2.sock"

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect(socket_path)

buf = ""
while True:
    buf += s.recv(4096).decode()
    while "\n" in buf:
        line, buf = buf.split("\n", 1)
        if line.startswith("monitoradded>>"):
            monitor = line[len("monitoradded>>"):]
            if monitor in ("DP-1", "DP-3"):
                for ws in range(1, 6):
                    subprocess.run(["hyprctl", "dispatch", "moveworkspacetomonitor", f"{ws} {monitor}"])
