#!/bin/bash

STATE=$(tailscale status --json 2>/dev/null | grep '"BackendState"' | cut -d'"' -f4)

case "$STATE" in
    Running)
        MY_IP=$(tailscale ip --4 2>/dev/null | tr -d '[:space:]')
        STATUS=$(tailscale status 2>/dev/null)
        TOTAL=$(echo "$STATUS" | grep -v "^#" | grep -v "^[[:space:]]*$" | tail -n +2 | grep -c .)
        ONLINE=$(echo "$STATUS" | grep -v "^#" | grep -v "^[[:space:]]*$" | tail -n +2 | grep -c "active")
        echo "{\"text\":\"󰒍\",\"class\":\"connected\",\"tooltip\":\"$MY_IP\\n$ONLINE/$TOTAL peers online\"}"
        ;;
    Stopped|NoState|"")
        echo "{\"text\":\"󰒎\",\"class\":\"disconnected\",\"tooltip\":\"Tailscale: disconnected\"}"
        ;;
    *)
        echo "{\"text\":\"󰒍\",\"class\":\"connecting\",\"tooltip\":\"Tailscale: $STATE\"}"
        ;;
esac
