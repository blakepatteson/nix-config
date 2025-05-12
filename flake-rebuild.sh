HOSTNAME=$(hostname)

if [[ "$1" == "-u" || "$1" == "--update" ]]; then
  echo "Updating flake inputs..."
  nix flake update
  shift
fi

ACTION=${1:-switch}
echo "Building configuration for $HOSTNAME ($ACTION)..."

# The key flags here: --impure, --override-input, and --option
sudo nixos-rebuild $ACTION \
  --impure \
  --option use-substituters true \
  --option substitute true \
  --option require-sigs false \
  --flake .#$HOSTNAME
