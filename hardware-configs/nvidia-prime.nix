{ config, ... }:
{
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Prime-specific environment variables for hybrid graphics
  environment.variables = {
    DRI_PRIME = "1";
    __NV_PRIME_RENDER_OFFLOAD = "0";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
  };
}
