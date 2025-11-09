{ pkgs, ... }:
{
  imports = [
    ./hyprland-config.nix
    ./niri-config.nix
  ];

  programs.hyprland = { enable = true; xwayland.enable = true; };
  programs.niri = { enable = true; };

  # Configure tuigreet for Hyprland/Niri login
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time \
          --remember --remember-user-session \
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

  # Bluetooth manager
  services.blueman.enable = true;

  powerManagement = {
    enable = false;
    powertop.enable = false;
    cpuFreqGovernor = "performance";
  };
}
