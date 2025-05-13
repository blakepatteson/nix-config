{ config, ... }:
{
  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = false;
    nvidiaSettings = true;
    forceFullCompositionPipeline = true; # This can fix some screen tearing issues
  };
}
