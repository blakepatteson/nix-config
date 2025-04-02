{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./boot.nix
    ./desktop.nix
    ./etc.nix
    ./env.nix
    ./hardware.nix
    ./network.nix
    ./nixvim.nix
    ./programs.nix
    ./programs-settings.nix
    ./system.nix
    ./services.nix
    ./virtualization.nix
  ];
}
