CLASS="$1"
LAUNCH_CMD="$2"

# Try to focus window, launch if not found
if hyprctl clients -j | jq -e ".[] | select(.class == \"$CLASS\")" > /dev/null 2>&1; then
    hyprctl dispatch focuswindow "class:^($CLASS)$" > /dev/null 2>&1
elif [ -n "$LAUNCH_CMD" ]; then
    hyprctl dispatch exec "$LAUNCH_CMD" > /dev/null 2>&1
fi
