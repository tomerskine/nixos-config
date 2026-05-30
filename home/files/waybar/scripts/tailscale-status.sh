#!/usr/bin/env bash

JSON=$(tailscale status --json 2>/dev/null)
STATE=$(echo "$JSON" | jq -r '.BackendState // empty' 2>/dev/null)

case "$STATE" in
    Running)
        MY_IP=$(echo "$JSON" | jq -r '.TailscaleIPs[0] // "unknown"' 2>/dev/null)
        TOTAL=$(echo "$JSON"  | jq '[.Peer // {} | .[]] | length' 2>/dev/null)
        ONLINE=$(echo "$JSON" | jq '[.Peer // {} | .[] | select(.Online == true)] | length' 2>/dev/null)
        echo "{\"text\":\"󰒍\",\"class\":\"connected\",\"tooltip\":\"$MY_IP\\n$ONLINE/$TOTAL peers online\"}"
        ;;
    Stopped|NoState|"")
        echo "{\"text\":\"󰒎\",\"class\":\"disconnected\",\"tooltip\":\"Tailscale: disconnected\"}"
        ;;
    *)
        echo "{\"text\":\"󰒍\",\"class\":\"connecting\",\"tooltip\":\"Tailscale: $STATE\"}"
        ;;
esac
