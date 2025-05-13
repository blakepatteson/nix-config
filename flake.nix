{
  description = "Blake's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { nixpkgs, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/desktop/hardware-configuration.nix
          ./configuration.nix
          { _module.args.isPrimeSystem = false; }
        ];
      };

      "nixos-laptop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/laptop/hardware-configuration.nix
          ./configuration.nix
          {
            _module.args.isPrimeSystem = true;
            networking.hostName = "nixos-laptop";
          }
        ];
      };
    };
  };
}
