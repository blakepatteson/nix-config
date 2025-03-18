{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./boot.nix
    ./desktop.nix
    ./etc.nix
    ./env.nix
    ./fonts.nix
    ./hardware.nix
    ./network.nix
    ./nixvim.nix
    ./programs.nix
    ./programs-settings.nix
    ./system.nix
    ./services.nix
    ./security.nix
    ./virtualization.nix
  ];
}
