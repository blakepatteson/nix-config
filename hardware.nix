# hardware.nix
{ lib, config, ... }:
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
    pulseaudio.enable = false;
    enableAllFirmware = true;
    opengl.enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
