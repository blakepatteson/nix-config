#!/bin/bash
HOSTNAME=$(hostname)
echo "Building configuration for $HOSTNAME..."
sudo nix --experimental-features "nix-command flakes" run nixpkgs#nixos-rebuild -- switch --flake .#$HOSTNAME
