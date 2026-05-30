#!/usr/bin/env bash

cliphist list \
    | rofi -dmenu -p "󰅍 Clipboard" \
        -theme-str 'window {width: 600px;} listview {lines: 12;}' \
    | cliphist decode \
    | wl-copy
