#!/usr/bin/env bash
sink="$1"
pactl set-default-sink "$sink"
pactl list sink-inputs short | awk '{print $1}' | xargs -I{} pactl move-sink-input {} "$sink"
