BOOTED=$(readlink /run/booted-system | xargs basename)
CURRENT=$(readlink /nix/var/nix/profiles/system | xargs basename)

echo "Generations (X = booted, -> = most recent):"
echo ""

sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | while read -r line; do
    GEN=$(echo "$line" | awk '{print $1}')
    if [ -n "$GEN" ]; then
        LINK=$(readlink /nix/var/nix/profiles/system-${GEN}-link 2>/dev/null | xargs basename)
        MARKER=""
        [ "$LINK" = "$BOOTED" ] && MARKER="X booted"
        [ "$LINK" = "$CURRENT" ] && MARKER="${MARKER:+$MARKER, }-> most recent"
        echo "$line${MARKER:+   ($MARKER)}"
    else
        echo "$line"
    fi
done
