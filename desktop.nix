{ pkgs, lib, ... }:
{
  imports = [
    ./hyprland-config.nix
  ];

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

  # Remove sessionPackages to avoid duplicates

  # Ensure desktop entries are created
  services.desktopManager.plasma6.enable = false;

  # Configure tuigreet to show session selector
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --sessions /etc/share/wayland-sessions --xsessions /etc/share/xsessions --xsession-wrapper '${pkgs.xorg.xinit}/bin/startx' --remember --remember-session";
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

  # Create working session files - use NixOS sessionPackages approach
  environment.etc."share/wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=Hyprland compositor
    Exec=${pkgs.hyprland}/bin/Hyprland
    Type=Application
    DesktopNames=Hyprland
  '';

  environment.etc."share/xsessions/cinnamon.desktop".text = ''
    [Desktop Entry]
    Name=Cinnamon
    Comment=Cinnamon Desktop Environment
    Exec=${pkgs.writeShellScript "cinnamon-wrapper" ''
      # Kill any Hyprland processes that might interfere
      pkill -f hyprland 2>/dev/null || true
      pkill -f Hyprland 2>/dev/null || true
  
      # Set up clean environment for Cinnamon (like main branch)
      export DESKTOP_SESSION=cinnamon
      export XDG_CURRENT_DESKTOP=X-Cinnamon
      export XDG_SESSION_DESKTOP=cinnamon
      export XDG_SESSION_TYPE=x11
  
      # Start Cinnamon the same way as main branch
      exec ${pkgs.cinnamon-session}/bin/cinnamon-session
    ''}
    Type=Application
    DesktopNames=X-Cinnamon
  '';

  # Fix X11 for Cinnamon with NVIDIA Prime support
  services.xserver.displayManager.startx.enable = true;

  # Fix Python and graphics environment for Cinnamon
  environment.variables = {
    # Python paths for Cinnamon components (fixes blueman/pygobject errors)
    PYTHONPATH = "${pkgs.python3}/lib/python3.11/site-packages:${pkgs.python3Packages.pygobject3}/lib/python3.11/site-packages";
    GI_TYPELIB_PATH = "${pkgs.gobject-introspection}/lib/girepository-1.0";
  };

  security.pam.services.greetd.enableGnomeKeyring = true;

  powerManagement = {
    enable = false;
    powertop.enable = false;
    cpuFreqGovernor = "performance";
  };
}
