#!/usr/bin/env bash
id=$(hyprctl activeworkspace -j | jq -r '.id')
current=$(hyprctl activeworkspace -j | jq -r '.name')

# Strip any existing "N: " prefix so re-renaming shows just the label
current_label=$(echo "$current" | sed 's/^[0-9]*: //')

new_name=$(echo "$current_label" | rofi -dmenu -p "Rename workspace $id:")

[[ $? -eq 0 && -n "$new_name" ]] && hyprctl dispatch renameworkspace "$id $id: $new_name"
