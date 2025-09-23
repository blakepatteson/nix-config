EMOJI_FILE="$HOME/offline-dev/zOther/_txt.txt"

if [ ! -f "$EMOJI_FILE" ]; then
    notify-send "Emoji Picker" "Emoji file not found: $EMOJI_FILE"
    exit 1
fi

# Use rofi to display emojis and get selection
selected=$(cat "$EMOJI_FILE" | rofi -dmenu -i -p "Pick an emoji" \
    -theme-str 'window {width: 60%;} listview {lines: 35;}')

if [ -n "$selected" ]; then
    emoji=$(echo "$selected" | awk '{print $1}')
    echo -n "$emoji" | xclip -selection clipboard
    sleep 0.2
    xdotool key --clearmodifiers ctrl+v
fi
