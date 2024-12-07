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
  };
}
