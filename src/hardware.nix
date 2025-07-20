{ config, pkgs, lib, ... }:
let
  isPrimeSystem = builtins.pathExists ./src/is-prime-system;
in
{
  hardware = {
    enableAllFirmware = true;

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
    } // lib.optionalAttrs isPrimeSystem {
      prime = {
        sync.enable = true; # Use sync instead of offload for display output
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
          AutoConnect = true;
        };
      };
    };
  };

  services.xserver.videoDrivers = [ "intel" "nvidia" ];
}
