{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./boot.nix
    ./env.nix
    ./etc.nix
    ./nixvim.nix
    ./programs.nix
    ./programs_settings.nix
  ];
}
