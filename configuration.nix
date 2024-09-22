{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./pkgs.nix
    ./utils.nix
  ];

  nixpkgs.config.allowUnfree = true;
  programs.firefox.enable = true;

  environment.variables = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.zlib
      pkgs.expat
      pkgs.minizip
    ];
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}