{ pkgs, ... }:
{
  imports = [ ./hyprland-config.nix ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Configure tuigreet for Hyprland login
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time \
          --cmd ${pkgs.hyprland}/bin/Hyprland --remember";
      user = "greeter";
    };
  };

  # Essential services
  services.dbus.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # Bluetooth manager
  services.blueman.enable = true;

  powerManagement = {
    enable = false;
    powertop.enable = false;
    cpuFreqGovernor = "performance";
  };
}
