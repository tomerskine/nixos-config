#!/usr/bin/env bash
# Trusted networks where auto-lock is suppressed
TRUSTED_NETWORKS=(
    "Keroppi"
)

CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '/^yes:/ { print $2 }')

for network in "${TRUSTED_NETWORKS[@]}"; do
    if [[ "$CURRENT_SSID" == "$network" ]]; then
        exit 1
    fi
done

exit 0
