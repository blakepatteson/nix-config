EMOJI_FILE="$HOME/offline-dev/zOther/_txt.txt"

if [ ! -f "$EMOJI_FILE" ]; then
    notify-send "Emoji Picker" "Emoji file not found: $EMOJI_FILE"
    exit 1
fi

# Use wofi for Wayland to display emojis and get selection
selected=$(cat "$EMOJI_FILE" | wofi --dmenu -i -p "Pick an emoji" --height 600 --width 800)

if [ -n "$selected" ]; then
    emoji=$(echo "$selected" | awk '{print $1}')
    # Use wl-copy for Wayland clipboard
    echo -n "$emoji" | wl-copy
    # Use wtype for Wayland keyboard input
    sleep 0.2
    wtype -M ctrl v -m ctrl
fi
