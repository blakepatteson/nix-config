{
  description = "Blake's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { nixpkgs, ... }: {
    nixosConfigurations = {
      # Desktop configuration (update hostname to match your desktop)
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit nixpkgs;
          isPrimeSystem = false; # Desktop likely doesn't need NVIDIA Prime
        };
        modules = [
          ./configuration.nix
        ];
      };

      # Laptop configuration (update hostname to match your laptop)
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit nixpkgs;
          isPrimeSystem = true; # Laptop with NVIDIA Prime
        };
        modules = [
          # Replace with your specific laptop model if available
          # nixos-hardware.nixosModules.lenovo-thinkpad-x1
          ./configuration.nix
          # Laptop-specific overrides
          {
            networking.hostName = "laptop";
          }
        ];
      };
    };
  };
}
