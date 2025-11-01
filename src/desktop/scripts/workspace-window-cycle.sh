# Get current workspace ID
CURRENT_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')

# Get all window addresses on current workspace only
mapfile -t WINDOWS < <(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $CURRENT_WORKSPACE) | .address")

# Get currently focused window
CURRENT=$(hyprctl activewindow -j | jq -r '.address')

# Find current window index
CURRENT_INDEX=-1
for i in "${!WINDOWS[@]}"; do
    if [[ "${WINDOWS[$i]}" == "$CURRENT" ]]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Calculate next/prev index
if [[ "$1" == "prev" ]]; then
    NEXT_INDEX=$(( (CURRENT_INDEX - 1 + ${#WINDOWS[@]}) % ${#WINDOWS[@]} ))
else
    NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WINDOWS[@]} ))
fi

# Focus the target window if we have windows
if [[ ${#WINDOWS[@]} -gt 0 ]] && [[ $NEXT_INDEX -ge 0 ]]; then
    hyprctl dispatch focuswindow address:${WINDOWS[$NEXT_INDEX]}
fi
