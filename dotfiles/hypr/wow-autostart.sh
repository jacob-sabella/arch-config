#!/bin/bash
# Wait for Battle.net window to appear, then launch WoW

TIMEOUT=120  # give up after 2 minutes

for ((i=0; i<TIMEOUT; i++)); do
    if hyprctl clients -j | python3 -c \
        "import sys,json; exit(0 if any(c['title']=='Battle.net' for c in json.load(sys.stdin)) else 1)" 2>/dev/null; then
        sleep 5  # give Battle.net a moment to finish initializing
        lutris lutris:rungame/world-of-warcraft
        exit 0
    fi
    sleep 1
done
