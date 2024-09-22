{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./pkgs.nix
    ./utils.nix
  ];
}