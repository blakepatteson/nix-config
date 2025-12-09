{ config, pkgs, lib, ... }:
let
  isPrimeSystem = builtins.pathExists ./is-prime-system;
in
{
  hardware = {
    enableAllFirmware = true;

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    nvidia = {
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.production.overrideAttrs (
        oldAttrs: rec {
          version = "580.95.05";
          src = pkgs.fetchurl {
            url = "https://us.download.nvidia.com/XFree86/Linux-x86_64/${
              version}/NVIDIA-Linux-x86_64-${version}.run";
            sha256 = "sha256-hJ7w746EK5gGss3p8RwTA9VPGpp2lGfk5dlhsv4Rgqc=";
          };
        }
      );
      modesetting.enable = true;
    } // lib.optionalAttrs isPrimeSystem {
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
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
          ControllerMode = "dual";
          FastConnectable = true;
        };
        Policy = { AutoEnable = true; };
      };
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Prevent module loading conflicts during boot (needed for Wayland compositors)
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  # Prevent Bluetooth from being suspended by USB autosuspend
  services.udev.extraRules = ''
    # Disable autosuspend for Bluetooth USB devices
    ACTION=="add", SUBSYSTEM=="usb", \
      ATTR{idVendor}=="8087", ATTR{idProduct}=="0026", \
      ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", DRIVER=="btusb", \
      ATTR{power/autosuspend}="-1"
  '';
}
