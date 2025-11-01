# Move all windows from monitor 1 to monitor 0
for window in $(hyprctl clients -j | jq -r '.[] | select(.monitor == 1) | .address'); do
    hyprctl dispatch focuswindow address:$window
    hyprctl dispatch movewindow mon:l
done

hyprctl dispatch focusmonitor 1 # Focus ultrawide (monitor 1) first so wofi appears there
sleep 0.2

# Get a dev directory using wofi (will appear on focused monitor)
SELECTED_DIR=$(find "$HOME/dev/repos" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | \
    wofi --show dmenu --insensitive)

if [ -n "$SELECTED_DIR" ]; then
    kitty --directory "$SELECTED_DIR" &
    sleep 0.2
    kitty --directory "$SELECTED_DIR" &
    # sleep 0.5
fi
