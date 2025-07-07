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
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --sessions /etc/wayland-sessions --xsessions /etc/xsessions --xsession-wrapper '${pkgs.xorg.xinit}/bin/startx' --remember --remember-session";
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

  # Create working session files in /etc locations
  environment.etc."wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=Hyprland compositor
    Exec=${pkgs.hyprland}/bin/Hyprland
    Type=Application
    DesktopNames=Hyprland
  '';

  environment.etc."xsessions/cinnamon.desktop".text = ''
    [Desktop Entry]
    Name=Cinnamon
    Comment=Cinnamon Desktop Environment
    Exec=${pkgs.writeShellScript "cinnamon-wrapper" ''
      # Set up environment for Cinnamon
      export DESKTOP_SESSION=cinnamon
      export XDG_CURRENT_DESKTOP=X-Cinnamon
      export XDG_SESSION_DESKTOP=cinnamon
      export XDG_SESSION_TYPE=x11
      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.cinnamon-common}/share:$XDG_DATA_DIRS"
      
      # Force Intel graphics for Cinnamon on Prime systems
      export DRI_PRIME=0
      export __GLX_VENDOR_LIBRARY_NAME=mesa
      unset __NV_PRIME_RENDER_OFFLOAD
      unset __VK_LAYER_NV_optimus
      
      # Ensure dbus session is available
      if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
        eval $(${pkgs.dbus}/bin/dbus-launch --sh-syntax --exit-with-session)
      fi
      
      # Start essential services
      ${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh &
      
      # Start Cinnamon with session manager
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

  # Add essential packages for Cinnamon
  environment.systemPackages = with pkgs; [
    gsettings-desktop-schemas
    cinnamon-common
    cinnamon-control-center
    muffin
  ];

  security.pam.services.greetd.enableGnomeKeyring = true;
  
  # Additional services for Cinnamon
  services.dbus.enable = true;
  services.gvfs.enable = true;
  services.gnome.gnome-keyring.enable = true;

  powerManagement = {
    enable = false;
    powertop.enable = false;
    cpuFreqGovernor = "performance";
  };
}
