{ ... }:
{
  services.displayManager = {
    defaultSession = "cinnamon";
    autoLogin = { enable = true; user = "blake"; };
  };

  services.xserver = {
    enable = true;

    displayManager.lightdm.enable = true;
    displayManager.gdm.autoSuspend = false;
    desktopManager.cinnamon.enable = true;

  };

  powerManagement = {
    enable = false;
    powertop.enable = false;
    cpuFreqGovernor = "performance";
  };
}
