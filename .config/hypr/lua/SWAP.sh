#!/bin/bash
# Swap between Lua config (primary) and hyprlang fallback.
# Lua is the default. This script exists as escape hatch if Lua breaks
# after a Hyprland upgrade. Takes effect on next session start (logout/login).

set -euo pipefail

CONF=~/.config/hypr/hyprland.conf
LUA_LINK=~/.config/hypr/hyprland.lua
LUA_TARGET=~/.config/hypr/lua/hyprland.lua
BACKUP=~/.config/hypr/hyprland.conf.bak.lua-swap

case "${1:-status}" in
  on)
    if [ -f "$CONF" ] && [ ! -L "$CONF" ]; then
      mv "$CONF" "$BACKUP"
      echo "moved $CONF -> $BACKUP"
    fi
    if [ ! -L "$LUA_LINK" ]; then
      ln -sf "$LUA_TARGET" "$LUA_LINK"
      echo "symlinked $LUA_LINK -> $LUA_TARGET"
    fi
    echo "Lua config ARMED."
    ;;

  off)
    if [ -L "$LUA_LINK" ]; then
      rm "$LUA_LINK"
      echo "removed $LUA_LINK"
    fi
    if [ -f "$BACKUP" ]; then
      mv "$BACKUP" "$CONF"
      echo "restored $CONF from backup"
    fi
    echo "Hyprlang config ARMED."
    ;;

  status)
    echo "==== ~/.config/hypr ===="
    ls -la ~/.config/hypr/hyprland.* 2>&1 | grep -E 'hyprland\.(conf|lua)' || true
    echo
    if [ -L "$LUA_LINK" ]; then
      echo "MODE: lua (next login will use Lua config from $LUA_TARGET)"
    elif [ -f "$CONF" ]; then
      echo "MODE: hyprlang (next login will use HLDE conf.d)"
    else
      echo "MODE: NEITHER — Hyprland will autogenerate fallback"
    fi
    ;;

  *)
    echo "usage: $0 [on|off|status]"
    exit 1
    ;;
esac
