#!/bin/bash

CHOSEN=$(printf "󰌾 Lock\n⏾ Suspend\n󰑓 Reboot\n⏻ Shutdown" \
    | rofi -dmenu -i -p "Power" -theme-str 'window {width: 220px;} listview {lines: 4;}')

case "$CHOSEN" in
    *Lock)     swaylock ;;
    *Suspend)  systemctl suspend ;;
    *Reboot)   systemctl reboot ;;
    *Shutdown) systemctl poweroff ;;
esac
