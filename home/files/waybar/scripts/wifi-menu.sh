#!/usr/bin/env bash

nmcli device wifi rescan 2>/dev/null

CURRENT=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | sed 's/^yes://')

mapfile -t SSIDS < <(
    nmcli --fields SSID device wifi list 2>/dev/null \
        | tail -n +2 \
        | sed 's/^[[:space:]]*//' \
        | sed 's/[[:space:]]*$//' \
        | grep -v '^$' \
        | sort -u
)

MENU_ITEMS=()
[ -n "$CURRENT" ] && MENU_ITEMS+=("󰖪  Disconnect: $CURRENT")
for ssid in "${SSIDS[@]}"; do
    MENU_ITEMS+=("$ssid")
done

CHOSEN=$(printf '%s\n' "${MENU_ITEMS[@]}" | rofi -dmenu -i -p "󰖩 WiFi" -theme-str 'window {width: 450px;}')
[ -z "$CHOSEN" ] && exit 0

if [[ "$CHOSEN" == "󰖪"* ]]; then
    WIFI_DEV=$(nmcli -t -f device,type dev | grep ':wifi' | cut -d: -f1 | head -1)
    nmcli device disconnect "$WIFI_DEV" && notify-send "WiFi" "Disconnected"
    exit 0
fi

SSID="$CHOSEN"

if nmcli connection show "$SSID" &>/dev/null 2>&1; then
    nmcli connection up id "$SSID" \
        && notify-send "WiFi" "Connected to $SSID" \
        || notify-send "WiFi" "Failed to connect to $SSID"
else
    IS_SECURED=$(nmcli device wifi list ssid "$SSID" 2>/dev/null | grep -cE 'WPA|WEP')
    if [ "$IS_SECURED" -gt 0 ]; then
        PASS=$(rofi -dmenu -password -p "Password for $SSID")
        [ -z "$PASS" ] && exit 0
        nmcli device wifi connect "$SSID" password "$PASS" \
            && notify-send "WiFi" "Connected to $SSID" \
            || notify-send "WiFi" "Failed to connect to $SSID"
    else
        nmcli device wifi connect "$SSID" \
            && notify-send "WiFi" "Connected to $SSID" \
            || notify-send "WiFi" "Failed to connect to $SSID"
    fi
fi
