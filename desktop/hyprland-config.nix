{ ... }:
let
  # Use same detection method as hardware.nix
  isPrimeSystem = builtins.pathExists ../hardware-configs/is-prime-system;

  # Read external config files
  monitorConfig = builtins.readFile (if isPrimeSystem
  then ./configs/monitors-laptop.conf
  else ./configs/monitors-desktop.conf);
  hyprlandBaseConfig = builtins.readFile ./configs/hyprland-base.conf;
  waybarConfig = builtins.readFile ./configs/waybar-config.json;
  waybarStyle = builtins.readFile ./configs/waybar-style.css;
  wofiConfig = builtins.readFile ./configs/wofi.conf;
  hyprpaperConfig = builtins.readFile ./configs/hyprpaper.conf;
in
{
  # Copy config during system activation
  system.activationScripts.hyprland-config = ''
        mkdir -p /home/blake/.config/hypr
        cat > /home/blake/.config/hypr/hyprland.conf << 'HYPR_EOF'
    ${monitorConfig}

    ${hyprlandBaseConfig}
    HYPR_EOF
        chown blake:users /home/blake/.config/hypr/hyprland.conf
        chmod 644 /home/blake/.config/hypr/hyprland.conf
    
        # Create hyprpaper config
        mkdir -p /home/blake/.config/hypr
        cat > /home/blake/.config/hypr/hyprpaper.conf << 'EOF'
    ${hyprpaperConfig}
    EOF
        chown blake:users /home/blake/.config/hypr/hyprpaper.conf
        chmod 644 /home/blake/.config/hypr/hyprpaper.conf
    
        # Create wofi config
        mkdir -p /home/blake/.config/wofi
        cat > /home/blake/.config/wofi/config << 'EOF'
    ${wofiConfig}
    EOF
        chown blake:users /home/blake/.config/wofi/config
        chmod 644 /home/blake/.config/wofi/config
        
        # Create waybar config
        mkdir -p /home/blake/.config/waybar
        cat > /home/blake/.config/waybar/config << 'WAYBAR_EOF'
    ${waybarConfig}
    WAYBAR_EOF
        chown blake:users /home/blake/.config/waybar/config
        chmod 644 /home/blake/.config/waybar/config

        cat > /home/blake/.config/waybar/style.css << 'WAYBAR_STYLE_EOF'
    ${waybarStyle}
    WAYBAR_STYLE_EOF
        chown blake:users /home/blake/.config/waybar/style.css
        chmod 644 /home/blake/.config/waybar/style.css
    
        # Create scripts directory and scripts
        mkdir -p /home/blake/.config/hypr/scripts
    
        # Create window switcher script
        cat > /home/blake/.config/hypr/scripts/window-switcher.sh << 'EOF'
    #!/bin/bash
    # Get list of windows with their info
    WINDOWS=$(hyprctl clients -j | jq -r '.[] | "\(.address)|\(.class)|\(.title)"')

    # Create wofi input format
    WOFI_INPUT=""
    while IFS='|' read -r address class title; do
        if [ -n "$title" ]; then
            WOFI_INPUT="$WOFI_INPUT$class: $title\n"
        fi
    done <<< "$WINDOWS"

    # Show wofi and get selection
    SELECTION=$(echo -e "$WOFI_INPUT" | wofi --show dmenu --allow-images --width 800 --height 500 --prompt "Switch to window...")

    if [ -n "$SELECTION" ]; then
        # Extract the title from selection and find the corresponding window
        SELECTED_TITLE=$(echo "$SELECTION" | sed 's/.*: //')
        WINDOW_ADDRESS=$(hyprctl clients -j | jq -r ".[] | select(.title == \"$SELECTED_TITLE\") | .address")
    
        if [ -n "$WINDOW_ADDRESS" ]; then
            hyprctl dispatch focuswindow address:$WINDOW_ADDRESS
        fi
    fi
    EOF
        chmod +x /home/blake/.config/hypr/scripts/window-switcher.sh
        chown blake:users /home/blake/.config/hypr/scripts/window-switcher.sh
    
        # Create working window switch script
        cat > /home/blake/.config/hypr/scripts/window-switch.sh << 'EOF'
    #!/bin/bash
    # Get windows and format for wofi
    SELECTION=$(hyprctl clients -j | jq -r '.[] | "\(.class): \(.title) |\(.address)"' | wofi --show dmenu --prompt "Switch to window...")

    if [ -n "$SELECTION" ]; then
        # Extract address from selection
        ADDRESS=$(echo "$SELECTION" | sed 's/.*|//')
        hyprctl dispatch focuswindow address:$ADDRESS
    fi
    EOF
        chmod +x /home/blake/.config/hypr/scripts/window-switch.sh
        chown blake:users /home/blake/.config/hypr/scripts/window-switch.sh
  '';
}

