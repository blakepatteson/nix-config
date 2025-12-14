{ pkgs, ... }:
{
  imports = [ ./niri-config.nix ];

  programs.niri = { enable = true; };
  programs.xwayland.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time \
          --remember --remember-user-session \
          --user-menu --asterisks";
      user = "greeter";
    };
    settings.initial_session = {
      command = "${pkgs.niri}/bin/niri-session";
      user = "blake";
    };
  };

  security.pam.services.greetd.enableGnomeKeyring = true;
  services = {
    dbus.enable = true;
    gnome.gnome-keyring.enable = true;
    blueman.enable = true;
  };
  powerManagement = {
    enable = false;
    powertop.enable = false;
    cpuFreqGovernor = "performance";
  };
}
