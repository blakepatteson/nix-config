{ config, pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_6_1;
  boot.initrd.includeDefaultModules = true;
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ nvidia_x11 ];
}
