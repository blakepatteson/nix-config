time sudo nixos-rebuild switch --cores 16 && niri msg action load-config-file
nix store diff-closures /run/booted-system /run/current-system

