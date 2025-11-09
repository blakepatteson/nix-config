{ ... }:
let
  # Use same detection method as hardware.nix - is it for laptop or desktop?
  isPrimeSystem = builtins.pathExists ../is-prime-system;

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
  system.activationScripts.hyprland-config = /* bash */ ''
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
  '';
}

