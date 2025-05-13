HOSTNAME=$(hostname)

if [[ "$1" == "-u" || "$1" == "--update" ]]; then
  echo "Updating flake inputs..."
  nix flake update
  shift
fi

ACTION=${1:-switch}
echo "Building configuration for $HOSTNAME ($ACTION)..."

# Use the system channel
sudo nixos-rebuild $ACTION \
  --impure \
  -I nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos \
  --flake .#$HOSTNAME
