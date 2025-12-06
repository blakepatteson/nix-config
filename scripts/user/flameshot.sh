# Create a permanent file for the screenshot
mkdir -p "$HOME/dev/screenshots"
tmp_file="$HOME/dev/screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png"

# Use grim + slurp for pure Wayland screenshot (no window management interference)
grim -g "$(slurp)" "$tmp_file"

# Check if the file exists and has size (meaning a screenshot was actually taken)
if [ -s "$tmp_file" ]; then
    # Copy to clipboard for immediate paste workflow
    wl-copy < "$tmp_file"

    # Open the screenshot in swappy for editing (Wayland-native)
    swappy -f "$tmp_file" &

    # Keep the screenshot file permanently in ~/Pictures/Screenshots/
    # No longer removing the temp file since it's now saved permanently
    wait
fi
