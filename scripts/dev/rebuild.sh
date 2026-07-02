cd "$(dirname "$0")/../.." || exit
HOST="${1:-$(hostname)}"
time sudo nixos-rebuild switch --flake ".#$HOST" --impure --cores 16 && niri msg action load-config-file
nix store diff-closures /run/booted-system /run/current-system
