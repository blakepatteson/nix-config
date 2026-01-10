{ ... }:
let
  niriConfig = builtins.readFile ./configs/niri.kdl;
  dunstConfig = builtins.readFile ./configs/dunstrc;
  waybarConfig = builtins.readFile ./configs/waybar-config.json;
  waybarStyle = builtins.readFile ./configs/waybar-style.css;
in
{
  system.activationScripts.niri-config = /* bash */ ''
        mkdir -p /home/blake/.config/niri
        cat > /home/blake/.config/niri/config.kdl << 'NIRI_EOF'
    ${niriConfig}
    NIRI_EOF
        chown blake:users /home/blake/.config/niri/config.kdl
        chmod 644 /home/blake/.config/niri/config.kdl
  '';

  system.activationScripts.dunst-config = /* bash */ ''
        mkdir -p /home/blake/.config/dunst
        cat > /home/blake/.config/dunst/dunstrc << 'DUNST_EOF'
    ${dunstConfig}
    DUNST_EOF
        chown blake:users /home/blake/.config/dunst/dunstrc
        chmod 644 /home/blake/.config/dunst/dunstrc
  '';

  system.activationScripts.waybar-config = /* bash */ ''
        mkdir -p /home/blake/.config/waybar
        cat > /home/blake/.config/waybar/config.json << 'WAYBAR_CONFIG_EOF'
    ${waybarConfig}
    WAYBAR_CONFIG_EOF
        cat > /home/blake/.config/waybar/style.css << 'WAYBAR_STYLE_EOF'
    ${waybarStyle}
    WAYBAR_STYLE_EOF
        chown blake:users /home/blake/.config/waybar/config.json
        chown blake:users /home/blake/.config/waybar/style.css
        chmod 644 /home/blake/.config/waybar/config.json
        chmod 644 /home/blake/.config/waybar/style.css
  '';
}
