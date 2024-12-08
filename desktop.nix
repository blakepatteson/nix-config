{ ... }:
{
  services.displayManager.defaultSession = "cinnamon";
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm.enable = true;
      gdm.autoSuspend = false;
    };
    desktopManager.cinnamon = {
      enable = true;
      extraGSettingsOverrides = ''
        [org.cinnamon.desktop.session]
        idle-delay=uint32 0

        [org.cinnamon.settings-daemon.plugins.power]
        sleep-display-ac=0
        sleep-inactive-ac-timeout=0
        idle-dim-time=0
        sleep-inactive-battery-timeout=0

        [org.cinnamon.desktop.screensaver]
        lock-enabled=false

        [org.cinnamon]
        enabled-applets=['panel1:left:0:menu@cinnamon.org', 'panel1:left:1:show-desktop@cinnamon.org', 'panel1:left:2:grouped-window-list@cinnamon.org', 'panel1:right:0:systray@cinnamon.org', 'panel1:right:1:xapp-status@cinnamon.org', 'panel1:right:2:notifications@cinnamon.org', 'panel1:right:3:printers@cinnamon.org', 'panel1:right:4:removable-drives@cinnamon.org', 'panel1:right:5:network@cinnamon.org', 'panel1:right:6:sound@cinnamon.org', 'panel1:right:7:power@cinnamon.org', 'panel1:right:8:calendar@cinnamon.org', 'panel1:right:9:systray@cinnamon.org', 'panel1:right:10:cpu@cinnamon.org', 'panel1:right:11:memory@cinnamon.org', 'panel1:right:12:temperature@fevimu']

        [org.cinnamon.applets.power@cinnamon.org]
        show-percentage=true

        [org.cinnamon.applets.cpu@cinnamon.org]
        show-text=true

        [org.cinnamon.applets.memory@cinnamon.org]
        show-percentage=true

        [org.cinnamon.applets.temperature@fevimu]
        interval=2
        show-unit=true
        show-unit-letter=true
        show-decimal-value=true
      '';
    };
  };
  powerManagement = { enable = false; powertop.enable = false; };
}