#!/usr/bin/env bash
OUTPUT=$(niri msg outputs | grep '^Output' | cut -d'(' -f 2 | cut -d')' -f 1 | wofi --dmenu --prompt 'Mirror which output? ')
if [ -n "$OUTPUT" ]; then
  wl-mirror "$OUTPUT"
fi
