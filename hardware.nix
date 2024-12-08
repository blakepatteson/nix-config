{ config, lib, ... }:
let
  nixosVersion = lib.versions.majorMinor lib.version;
  isOldVersion = nixosVersion < "23.11";
in
{
  hardware = {
    pulseaudio.enable = false;
    enableAllFirmware = true;
  } // (if isOldVersion then {
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
  } else {
    graphics.enable = true;
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      # Prime settings commented out for newer version
    };
  });
  services.xserver.videoDrivers = [ "nvidia" ];
}
