#!/bin/bash

SOCKET=$(ls $XDG_RUNTIME_DIR/hypr/*/.socket2.sock 2>/dev/null | head -1)

if [[ -z "$SOCKET" ]]; then
  echo "Could not find Hyprland socket" >&2
  exit 1
fi

wow_running() {
  hyprctl clients -j | python3 -c \
    "import sys,json; exit(0 if any(c['title']=='World of Warcraft' for c in json.load(sys.stdin)) else 1)"
}

bnet_running() {
  hyprctl clients -j | python3 -c \
    "import sys,json; exit(0 if any(c['title']=='Battle.net' for c in json.load(sys.stdin)) else 1)"
}

set_wow_priority() {
  local nice=$1
  pgrep -f "Wow.exe" | while read pid; do
    renice -n "$nice" -p "$pid" 2>/dev/null
  done
}

set_wow_mute() {
  local mute=$1
  pactl list sink-inputs | awk -v mute="$mute" '
        /Sink Input #/ { id = substr($3, 2) }
        /application.process.binary = "Wow.exe"/ { system("pactl set-sink-input-mute " id " " mute) }
    '
}

MONITOR="HDMI-A-2"

handle() {
  case $1 in
  workspace\>\>10)
    set_wow_mute 0
    set_wow_priority 0
    if ! wow_running; then
      if bnet_running; then
        lutris lutris:rungame/world-of-warcraft &
      else
        lutris lutris:rungame/battlenet &
      fi
    fi
    ;;
  workspace\>\>*)
    hyprctl keyword monitor "$MONITOR,7680x2160@120,auto,2"
    set_wow_mute 1
    set_wow_priority 10
    ;;
  esac
}

socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do handle "$line"; done
