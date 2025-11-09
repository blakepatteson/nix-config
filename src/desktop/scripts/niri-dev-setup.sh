#!/usr/bin/env bash
# Niri dev workspace setup: Pick directory and open two vertically stacked terminals

# Get a dev directory using wofi
SELECTED_DIR=$(find "$HOME/dev/repos" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | \
    wofi --show dmenu --insensitive --prompt "Select dev directory")

if [ -z "$SELECTED_DIR" ]; then
    exit 0
fi

# Open first terminal
kitty --directory "$SELECTED_DIR" &
sleep 0.2

# Open second terminal (will appear in same column, stacked vertically)
kitty --directory "$SELECTED_DIR" &
