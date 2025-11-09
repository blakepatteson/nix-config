{ ... }:
let niriConfig = builtins.readFile ./configs/niri.kdl; in
{
  # Copy niri config during system activation
  system.activationScripts.niri-config = /* bash */ ''
        mkdir -p /home/blake/.config/niri
        cat > /home/blake/.config/niri/config.kdl << 'NIRI_EOF'
    ${niriConfig}
    NIRI_EOF
        chown blake:users /home/blake/.config/niri/config.kdl
        chmod 644 /home/blake/.config/niri/config.kdl
  '';
}
