mkdir -p "$HOME/dev/screenshots"
tmp_file="$HOME/dev/screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png"
grim -g "$(slurp)" "$tmp_file"
if [ -s "$tmp_file" ]; then
    wl-copy < "$tmp_file"
    swappy -f "$tmp_file" &
    wait
fi
