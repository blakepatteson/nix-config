{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./src/boot.nix
    ./desktop/desktop.nix
    ./src/etc.nix
    ./src/env.nix
    ./src/hardware.nix
    ./src/network.nix
    ./src/nixvim.nix
    ./src/programs.nix
    ./src/programs-settings.nix
    ./src/system.nix
    ./src/services.nix
    ./src/virtualization.nix
  ];
}
