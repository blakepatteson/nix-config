{ pkgs, ... }:
{
  imports = [
    ./niri-config.nix
  ];

  programs.niri = { enable = true; };

  # Configure tuigreet for Niri login
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time \
          --remember --remember-user-session \
          --user-menu --asterisks";
      user = "greeter";
    };
    settings.initial_session = {
      command = "${pkgs.niri}/bin/niri-session";
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
