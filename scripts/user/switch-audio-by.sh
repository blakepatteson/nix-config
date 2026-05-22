pattern="$1"

if [ -z "$pattern" ]; then
  echo "usage: switch-audio-by <substring>" >&2
  echo "available sinks:" >&2
  pactl list sinks short | awk '{print "  " $2}' >&2
  exit 1
fi

sink=$(pactl list sinks short | awk '{print $2}' | grep -i -- "$pattern" | head -n1)

if [ -z "$sink" ]; then
  while read -r card; do
    profile=$(pactl list cards | awk -v c="$card" '
      $1 == "Name:" && $2 == c { in_card = 1; next }
      in_card && /^Card #/ { in_card = 0 }
      in_card && /Profiles:/ { in_profiles = 1; next }
      in_profiles && /^\t[A-Z]/ { in_profiles = 0 }
      in_profiles && /^\t\t/ {
        sub(/^\t\t/, "")
        sub(/:.*/, "")
        print
      }
    ' | grep -i -- "$pattern" | grep -v "^off$" | head -n1)
    if [ -n "$profile" ]; then
      pactl set-card-profile "$card" "$profile" 2>/dev/null
      sleep 0.2
      sink=$(pactl list sinks short | awk '{print $2}' | grep -i -- "$pattern" | head -n1)
      [ -n "$sink" ] && break
    fi
  done < <(pactl list cards short | awk '{print $2}')
fi

if [ -z "$sink" ]; then
  notify-send -u critical "switch-audio-by" "No sink matching: $pattern" 2>/dev/null
  echo "no sink matching: $pattern" >&2
  exit 1
fi

pactl set-default-sink "$sink"
pactl list sink-inputs short | awk '{print $1}' | \
  xargs -I{} pactl move-sink-input {} "$sink"
