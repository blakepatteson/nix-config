#!/usr/bin/env bash
# Kill current workspace by moving all windows to the previous workspace

# Get current focused workspace info
FOCUSED_WS=$(niri msg --json workspaces | jq -r '.[] | select(.is_focused == true)')

if [ -z "$FOCUSED_WS" ]; then
    echo "No focused workspace found"
    exit 1
fi

FOCUSED_OUTPUT=$(echo "$FOCUSED_WS" | jq -r '.output')
FOCUSED_IDX=$(echo "$FOCUSED_WS" | jq -r '.idx')

# Get all window IDs on the focused workspace
WINDOW_IDS=$(niri msg --json windows | jq -r ".[] | select(.workspace_id != null) | select(.workspace_id == $(echo "$FOCUSED_WS" | jq -r '.id')) | .id")

if [ -z "$WINDOW_IDS" ]; then
    echo "No windows on current workspace"
    exit 0
fi

# Move all windows to workspace above
for window_id in $WINDOW_IDS; do
    niri msg action move-window-to-workspace-up --window-id "$window_id"
done

# Focus the workspace above to trigger cleanup
niri msg action focus-workspace-up
