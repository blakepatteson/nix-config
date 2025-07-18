{ pkgs, ... }:
let
  # Use a static configuration file to determine hardware profile
  isPrimeSystem = builtins.pathExists ./hardware-configs/is-prime-system;
in
{
  imports = [
    (if isPrimeSystem
    then ./hardware-configs/nvidia-prime.nix
    else ./hardware-configs/nvidia-base.nix)
  ];

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

  services.xserver.videoDrivers = [ "nvidia" ];
}
