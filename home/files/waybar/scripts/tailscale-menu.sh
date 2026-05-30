#!/usr/bin/env bash

JSON=$(tailscale status --json 2>/dev/null)
STATE=$(echo "$JSON" | grep '"BackendState"' | cut -d'"' -f4)

if [ "$STATE" = "Running" ]; then
    CHOSEN=$(printf "󰒎 Disconnect\n󰒃 Copy my IP\n󰔛 SSH to peer\n󱄮 Ping a peer\n󰖟 Admin console" \
        | rofi -dmenu -i -p "󰒍 Tailscale" \
            -theme-str 'window {width: 260px;} listview {lines: 5;}')
else
    CHOSEN=$(printf "󰒍 Connect\n󰖟 Admin console" \
        | rofi -dmenu -i -p "󰒎 Tailscale" \
            -theme-str 'window {width: 260px;} listview {lines: 2;}')
fi

[ -z "$CHOSEN" ] && exit 0

# Build peer list as "● hostname (OS) — IP" for SSH/ping submenus
peer_menu() {
    echo "$JSON" | python3 -c "
import json, sys
d = json.load(sys.stdin)
for p in d.get('Peer', {}).values():
    status = '●' if p.get('Active') else '○'
    name = p['HostName']
    os_ = p.get('OS', '?')
    ip = p.get('TailscaleIPs', ['?'])[0]
    print(f'{status} {name} ({os_}) — {ip}')
"
}

case "$CHOSEN" in
    *Connect)
        sudo tailscale up \
            && notify-send "Tailscale" "Connected" \
            || notify-send "Tailscale" "Failed to connect"
        ;;
    *Disconnect)
        sudo tailscale down \
            && notify-send "Tailscale" "Disconnected" \
            || notify-send "Tailscale" "Failed to disconnect"
        ;;
    *"Copy my IP")
        IP=$(tailscale ip --4 2>/dev/null | tr -d '[:space:]')
        printf "%s" "$IP" | wl-copy && notify-send "Tailscale" "Copied: $IP"
        ;;
    *"SSH to peer")
        PEER=$(peer_menu | rofi -dmenu -i -p "SSH to" \
            -theme-str 'window {width: 380px;} listview {lines: 8;}')
        [ -z "$PEER" ] && exit 0
        IP=$(echo "$PEER" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
        [ -n "$IP" ] && kitty -e ssh "$IP"
        ;;
    *"Ping a peer")
        PEER=$(peer_menu | rofi -dmenu -i -p "Ping" \
            -theme-str 'window {width: 380px;} listview {lines: 8;}')
        [ -z "$PEER" ] && exit 0
        HOSTNAME=$(echo "$PEER" | awk '{print $2}')
        [ -n "$HOSTNAME" ] && kitty --hold -e tailscale ping "$HOSTNAME"
        ;;
    *"Admin console")
        xdg-open "https://login.tailscale.com/admin" &
        ;;
esac
