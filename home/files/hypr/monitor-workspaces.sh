#!/usr/bin/env python3
import json
import os
import socket
import subprocess
import time

EXTERNAL_MONITORS = ("DP-1", "DP-3")


def get_monitors():
    result = subprocess.run(["hyprctl", "-j", "monitors"], capture_output=True, text=True)
    return json.loads(result.stdout)


def has_external():
    return any(m["name"] in EXTERNAL_MONITORS for m in get_monitors())


def move_workspaces_to_external(monitor):
    for ws in range(1, 6):
        subprocess.run(["hyprctl", "dispatch", "moveworkspacetomonitor", f"{ws} {monitor}"])


def switch_to_workspace_1():
    subprocess.run(["hyprctl", "dispatch", "workspace", "1"])


# On startup: if laptop-only, default to workspace 1 instead of 6.
# Brief delay lets Hyprland finish monitor initialisation first.
time.sleep(0.5)
if not has_external():
    switch_to_workspace_1()

# Listen for monitor add/remove events
socket_path = (
    f"{os.environ['XDG_RUNTIME_DIR']}/hypr"
    f"/{os.environ['HYPRLAND_INSTANCE_SIGNATURE']}/.socket2.sock"
)
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect(socket_path)

buf = ""
while True:
    buf += s.recv(4096).decode()
    while "\n" in buf:
        line, buf = buf.split("\n", 1)

        if line.startswith("monitoradded>>"):
            monitor = line[len("monitoradded>>"):]
            if monitor in EXTERNAL_MONITORS:
                move_workspaces_to_external(monitor)

        elif line.startswith("monitorremoved>>"):
            monitor = line[len("monitorremoved>>"):]
            if monitor in EXTERNAL_MONITORS and not has_external():
                switch_to_workspace_1()
