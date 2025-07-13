#!/bin/bash

# List of apps that should pause Stretchly when foregrounded
WATCH_APPS=("Roam" "zoom.us" "Loom")

# Stretchly API endpoints
PAUSE_URL="http://localhost:8000/pause"
UNPAUSE_URL="http://localhost:8000/unpause"

# Track previous state to avoid duplicate notifications
PREVIOUS_STATE=""

# Function to send a macOS notification
notify() {
  TITLE="$1"
  MESSAGE="$2"
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
}

while true; do
  FRONTAPP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')

  if [[ " ${WATCH_APPS[*]} " =~ " ${FRONTAPP} " ]]; then
    if [[ "$PREVIOUS_STATE" != "paused" ]]; then
      curl -s "$PAUSE_URL"
      notify "Stretchly" "Paused due to ${FRONTAPP} being in the foreground"
      PREVIOUS_STATE="paused"
    fi
  else
    if [[ "$PREVIOUS_STATE" != "unpaused" ]]; then
      curl -s "$UNPAUSE_URL"
      notify "Stretchly" "Resumed (no tracked app in foreground)"
      PREVIOUS_STATE="unpaused"
    fi
  fi

  sleep 5
done

