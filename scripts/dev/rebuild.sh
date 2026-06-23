cd "$(dirname "$0")/../.."
time sudo nixos-rebuild switch --flake .#blake-nixos --impure --cores 16 && niri msg action load-config-file
nix store diff-closures /run/booted-system /run/current-system
