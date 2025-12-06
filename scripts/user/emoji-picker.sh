EMOJIS="😊
😜 crazy
🥰 am loved
😘 smooch
😍 love
🥵 hot
🥶 cold
🤗 hug
🤷 shrug
💪 muscle
😈 evil
😴 sleepy zzz
😎 cool
💦 splash
🥹 happy tears
👀 eyes
🙄 eye
🤮 vommit
🤔 think
🍆 eggplant
🥔 potato
⏰ clock
😋 yum
😬 yikes
😭 cry
👍 thumb
😵 dead
🤤 drool
😥 disappointed
😏 smirk
😅 sweat
😂"

selected=$(echo "$EMOJIS" | wofi --dmenu -i -p "Pick an emoji" \
  --height 600 --width 800)

if [ -n "$selected" ]; then
    emoji=$(echo "$selected" | awk '{print $1}')
    echo -n "$emoji" | wl-copy # Use wl-copy for Wayland clipboard
    sleep 0.2
    wtype -M ctrl v -m ctrl # Use wtype for Wayland keyboard input
fi
