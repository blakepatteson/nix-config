{ config, ... }:
{
  hardware = {
    pulseaudio.enable = false;
    enableAllFirmware = true;
    opengl.enable = true;
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Keep Prime if you have hybrid graphics
      prime = {
        offload.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];
}
