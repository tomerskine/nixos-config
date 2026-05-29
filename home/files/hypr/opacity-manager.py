#!/usr/bin/env python3
"""
Sets inactive_opacity only for windows on the same monitor as the focused window.
Windows on other monitors stay fully opaque.
"""
import json, os, socket, subprocess, time

INACTIVE_ALPHA = "0.85"

def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True).stdout

def update_opacity():
    try:
        active = json.loads(run(["hyprctl", "-j", "activewindow"]))
        clients = json.loads(run(["hyprctl", "-j", "clients"]))
    except Exception:
        return

    active_addr = active.get("address", "")
    active_monitor = active.get("monitor", -1)

    for client in clients:
        addr = client.get("address", "")
        if addr == active_addr or client.get("monitor", -1) != active_monitor:
            alpha = "1.0"
        else:
            alpha = INACTIVE_ALPHA
        subprocess.run(["hyprctl", "setprop", f"address:{addr}", "alpha", alpha, "lock", "0"])

time.sleep(0.5)
update_opacity()

sig = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
path = f"{os.environ['XDG_RUNTIME_DIR']}/hypr/{sig}/.socket2.sock"

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect(path)

buf = ""
while True:
    data = s.recv(4096).decode()
    if not data:
        break
    buf += data
    while "\n" in buf:
        line, buf = buf.split("\n", 1)
        if line.split(">>")[0] in ("activewindow", "focusedmon", "openwindow", "closewindow", "movewindow"):
            update_opacity()
