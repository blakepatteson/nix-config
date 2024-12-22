{ pkgs, ... }:
{
  services = {
    locate = {
      enable = true;
      package = pkgs.mlocate;
      interval = "hourly";
      localuser = null;
    };
    printing.enable = true;
    flatpak.enable = true;
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

  };
}
