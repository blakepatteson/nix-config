{ config, ... }:
{
  hardware = {
    pulseaudio.enable = false;
    enableAllFirmware = true;
    opengl.enable = true;
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        offload.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];
}
