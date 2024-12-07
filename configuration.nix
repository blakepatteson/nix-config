{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./hardware.nix
    ./virtualization.nix
    ./desktop.nix
    ./network.nix
    ./system.nix
    ./services.nix
    ./security.nix
    ./fonts.nix
    ./programs.nix
    ./etc.nix
    ./programs_settings.nix
    ./env.nix
    ./nixvim.nix
  ];
}
