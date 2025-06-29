{ pkgs, lib, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable Cinnamon as fallback desktop
  services.xserver = {
    enable = true;
    desktopManager.cinnamon.enable = true;
    displayManager.lightdm.enable = lib.mkForce false;
  };
  
  # Fix the deprecated option
  services.displayManager.sessionPackages = [ pkgs.hyprland pkgs.cinnamon.cinnamon-session ];
  
  # Ensure desktop entries are created
  services.desktopManager.plasma6.enable = false;

  # Copy config during system activation
  system.activationScripts.hyprland-config = ''
    mkdir -p /home/blake/.config/hypr
    cat > /home/blake/.config/hypr/hyprland.conf << 'EOF'
# Monitor configuration
monitor = ,preferred,auto,auto

# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = false
    }
    sensitivity = 0
}

# General settings
general {
    gaps_in = 0
    gaps_out = 0
    border_size = 0
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# Disable Hyprland branding/help
misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    force_default_wallpaper = 0
}

# Decoration
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animations - disabled for instant switching
animations {
    enabled = false
}

# Dwindle layout
dwindle {
    pseudotile = true
    preserve_split = true
    force_split = 2
}

# Window rules - make new windows fullscreen by default
windowrulev2 = fullscreen, class:^(.*)

# Key bindings
$mainMod = SUPER

# Application shortcuts
bind = $mainMod, Q, exec, kitty
bind = $mainMod, F, exec, firefox
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, kitty -e nvim
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, wofi --show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,
bind = $mainMod, B, exec, pkill -SIGUSR1 waybar

# Windows-style app launcher
bind = SUPER, SUPER_L, exec, wofi --show drun --allow-images --width 600 --height 400 --prompt "Search apps..."

# Window overview/switcher - simple working version
bind = $mainMod, W, exec, hyprctl clients -j | jq -r '.[] | "\(.class): \(.title)"' | wofi --show dmenu --prompt "Switch to window..." | head -1 | sed 's/.*: //' | xargs -I {} hyprctl dispatch focuswindow "title:{}"

# Fullscreen controls
bind = $mainMod, up, fullscreen, 1
bind = $mainMod SHIFT, up, fullscreen, 0
bind = $mainMod, down, fullscreen, 0

# Alt+Tab functionality
bind = ALT, Tab, cyclenext,
bind = ALT SHIFT, Tab, cyclenext, prev

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Screenshot
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy

# Mouse bindings
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Execute on startup - FORCE pure black background
exec-once = waybar
exec-once = killall hyprpaper swww swaybg || true
exec-once = hyprctl keyword misc:disable_hyprland_logo true
exec-once = hyprctl keyword misc:disable_splash_rendering true
exec-once = swaybg -c "#000000"
EOF
    chown blake:users /home/blake/.config/hypr/hyprland.conf
    chmod 644 /home/blake/.config/hypr/hyprland.conf
    
# Create hyprpaper config for pure black background
    mkdir -p /home/blake/.config/hypr
    cat > /home/blake/.config/hypr/hyprpaper.conf << 'EOF'
preload = 
wallpaper = ,#000000
splash = false
EOF
    chown blake:users /home/blake/.config/hypr/hyprpaper.conf
    chmod 644 /home/blake/.config/hypr/hyprpaper.conf
    
    # Create wofi config for Windows-style launcher
    mkdir -p /home/blake/.config/wofi
    cat > /home/blake/.config/wofi/config << 'EOF'
width=600
height=400
location=center
show=drun
prompt=Search apps...
filter_rate=100
allow_markup=true
no_actions=true
halign=fill
orientation=vertical
content_halign=fill
insensitive=true
allow_images=true
image_size=32
gtk_dark=true
EOF
    chown blake:users /home/blake/.config/wofi/config
    chmod 644 /home/blake/.config/wofi/config
    
    # Create alt-tab script
    mkdir -p /home/blake/.config/hypr/scripts
    cat > /home/blake/.config/hypr/scripts/alttab.sh << 'EOF'
#!/bin/bash
if [ "$1" = "next" ]; then
    hyprctl dispatch cyclenext
else
    hyprctl dispatch cyclenext prev
fi

# Show notification with current window
CURRENT_WINDOW=$(hyprctl activewindow -j | jq -r '.title')
notify-send -t 1000 "Window Switch" "$CURRENT_WINDOW"
EOF
    chmod +x /home/blake/.config/hypr/scripts/alttab.sh
    chown blake:users /home/blake/.config/hypr/scripts/alttab.sh
    
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

  # Configure tuigreet to show session selector
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --sessions /usr/share/wayland-sessions:/etc/wayland-sessions --xsessions /usr/share/xsessions:/etc/xsessions --remember --remember-session";
        user = "greeter";
      };
    };
  };

  # Force disable conflicting display manager
  services.displayManager.enable = lib.mkForce false;
  
  # Fix session files and PAM configuration
  environment.etc."greetd/environments".text = ''
Hyprland
cinnamon-session
  '';
  
  # Create proper .desktop files for sessions  
  environment.etc."wayland-sessions/hyprland.desktop".text = ''
[Desktop Entry]
Name=Hyprland
Comment=Hyprland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
  '';
  
  environment.etc."xsessions/cinnamon.desktop".text = ''
[Desktop Entry]
Name=Cinnamon
Comment=Cinnamon Desktop Environment
Exec=cinnamon-session
Type=Application
DesktopNames=X-Cinnamon
  '';
  
  security.pam.services.greetd.enableGnomeKeyring = true;
  
  # Debug what tuigreet can see
  systemd.tmpfiles.rules = [
    "d /usr/share/wayland-sessions 0755 root root"
    "d /usr/share/xsessions 0755 root root"
    "L+ /usr/share/wayland-sessions/hyprland.desktop - - - - /etc/wayland-sessions/hyprland.desktop"
    "L+ /usr/share/xsessions/cinnamon.desktop - - - - /etc/xsessions/cinnamon.desktop"
    "f /tmp/tuigreet-debug.log 0644 root root"
  ];

  environment.systemPackages = with pkgs; [
    waybar
    wofi
    dunst
    hyprpaper
    grim
    slurp
    wl-clipboard
    brightnessctl
    pamixer
    libnotify
    jq
    imagemagick
    swaybg
  ];

  powerManagement = {
    enable = false;
    powertop.enable = false;
    cpuFreqGovernor = "performance";
  };
}
