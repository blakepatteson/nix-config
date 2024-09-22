{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./programs.nix
    ./etc.nix
    ./programs_settings.nix
    ./env.nix
  ];
}