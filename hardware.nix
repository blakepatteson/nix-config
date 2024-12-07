{ config, ... }:
{
  hardware = {
    pulseaudio.enable = false;
    enableAllFirmware = true;
    graphics.enable = true;
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];
}
