{ pkgs, lib, ... }:
{
  services = {
    syncthing = {
      enable = true;
      user = "blake";
      dataDir = "/home/blake/Sync";
      configDir = "/home/blake/.config/syncthing";
      openDefaultPorts = true;
    };

    locate = {
      enable = true;
      package = pkgs.mlocate;
      interval = "hourly";
      localuser = null;
    };

    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
      browsing = true;
      startWhenNeeded = true;
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    flatpak.enable = lib.mkDefault false;
    openssh.enable = true;
    fstrim.enable = true;
    timesyncd.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    picom.enable = false;

    xrdp = {
      enable = true;
      defaultWindowManager = "cinnamon-session-cinnamon";
      openFirewall = true;
    };
  };
}
