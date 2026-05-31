#!/usr/bin/env bash
id=$(hyprctl activeworkspace -j | jq -r '.id')
current=$(hyprctl activeworkspace -j | jq -r '.name')

# Strip any existing "N: " prefix so re-renaming shows just the label
current_label=$(echo "$current" | sed 's/^[0-9]*: //')

new_name=$(echo "$current_label" | rofi -dmenu -p "Rename workspace $id:")

# hyprctl dispatch in Lua config mode requires valid Lua: hl.dsp.workspace.rename(...)
[[ $? -eq 0 && -n "$new_name" ]] && \
    hyprctl dispatch "hl.dsp.workspace.rename({workspace=$id, name=\"$id: $new_name\"})"
