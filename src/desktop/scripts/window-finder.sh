# Get list of ALL windows across all workspaces with workspace info
WINDOWS=$(hyprctl clients -j | jq -r '.[] | "\(.address)|\(.workspace.id)|\(.monitor)|\(.class)|\(.title)"')

# Create wofi input format with workspace info
WOFI_INPUT=""
while IFS='|' read -r address workspace monitor class title; do
    if [ -n "$title" ]; then
        WOFI_INPUT="$WOFI_INPUT[WS$workspace] $class: $title|$address\n"
    fi
done <<< "$WINDOWS"

# Show wofi and get selection
SELECTION=$(echo -e "$WOFI_INPUT" | \
    wofi --show dmenu --width 1000 --height 600 \
    --prompt "Find window (all workspaces)..." --insensitive)

if [ -n "$SELECTION" ]; then
    # Extract the address from selection (after the |)
    WINDOW_ADDRESS=$(echo "$SELECTION" | sed 's/.*|//')

    if [ -n "$WINDOW_ADDRESS" ]; then
        # Focus the window (this will automatically switch workspace if needed)
        hyprctl dispatch focuswindow address:$WINDOW_ADDRESS
    fi
fi
