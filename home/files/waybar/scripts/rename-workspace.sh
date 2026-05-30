#!/usr/bin/env bash
id=$(hyprctl activeworkspace -j | jq -r '.id')
current=$(hyprctl activeworkspace -j | jq -r '.name')

new_name=$(echo "$current" | rofi -dmenu -p "Rename workspace $id:")

[[ $? -eq 0 && -n "$new_name" ]] && hyprctl dispatch renameworkspace "$id" "$new_name"
