{
  description = "main nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, nixvim, ... }:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      mkHost = { hostModule, isPrimeSystem }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs-unstable isPrimeSystem; };
        modules = [
          nixvim.nixosModules.nixvim
          hostModule
          ./configuration.nix
        ];
      };
    in
    {
      nixosConfigurations.blake-nixos = mkHost {
        hostModule = ./hosts/desktop.nix;
        isPrimeSystem = false;
      };
      nixosConfigurations.blake-laptop = mkHost {
        hostModule = ./hosts/laptop.nix;
        isPrimeSystem = true;
      };
    };
}
