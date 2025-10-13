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
          --cmd ${pkgs.hyprland}/bin/Hyprland --remember --remember-user-session \
          --user-menu --asterisks";
      user = "greeter";
    };
    settings.initial_session = {
      command = "${pkgs.hyprland}/bin/Hyprland";
      user = "blake";
    };
  };

  # Essential services
  services.dbus.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  powerManagement = {
    enable = false;
    powertop.enable = false;
    cpuFreqGovernor = "performance";
  };
}
