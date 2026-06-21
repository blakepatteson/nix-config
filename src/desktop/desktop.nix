{ pkgs, ... }:
{
  imports = [ ./niri-config.nix ];

  programs.niri = { enable = true; };
  programs.xwayland.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
    ];
  };
  services.tumbler.enable = true;
  services.gvfs.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.common = {
      default = [ "kde" "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
    };
  };

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
