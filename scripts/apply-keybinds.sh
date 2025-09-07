# Power and session settings
dconf write /org/cinnamon/desktop/session/idle-delay "uint32 0"
dconf write /org/cinnamon/settings-daemon/plugins/power/sleep-display-ac "0"
dconf write /org/cinnamon/settings-daemon/plugins/power/sleep-inactive-ac-timeout "0"
dconf write /org/cinnamon/settings-daemon/plugins/power/idle-dim-time "0"
dconf write /org/cinnamon/settings-daemon/plugins/power/sleep-inactive-battery-timeout "0"
dconf write /org/cinnamon/desktop/screensaver/lock-enabled "false"

# Window list settings - no grouping, no pinned apps
dconf write /org/cinnamon/applets/grouped-window-list/group-windows "false"
dconf write /org/cinnamon/applets/grouped-window-list/pinned-apps "@as []"

# Calendar/clock date format
dconf write /org/cinnamon/desktop/interface/clock-use-24h "false"
dconf write /org/cinnamon/desktop/interface/clock-show-seconds "true"
dconf write /org/cinnamon/desktop/interface/clock-show-date "true"

# Keyboard shortcuts
dconf reset -f /org/cinnamon/desktop/keybindings/custom-keybindings/
dconf write /org/cinnamon/desktop/keybindings/custom-list "['custom0', 'custom1', 'custom2']"

dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/name "'Screenshot (Flameshot)'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/command "'flameshot gui'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/binding "['Print']"

dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom1/name "'Flameshot Launcher'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom1/command "'flameshot launcher'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom1/binding "['<Control>Print']"

dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom2/name "'Emoji Picker'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom2/command "'/home/blake/dev/repos/nix-config/scripts/emoji-picker.sh'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom2/binding "['<Super>q']"

# Disable default screenshot shortcuts
dconf write /org/cinnamon/desktop/keybindings/media-keys/screenshot "@as []"
dconf write /org/cinnamon/desktop/keybindings/media-keys/screenshot-clip "@as []"
dconf write /org/cinnamon/desktop/keybindings/media-keys/area-screenshot "@as []"
dconf write /org/cinnamon/desktop/keybindings/media-keys/area-screenshot-clip "@as []"
dconf write /org/cinnamon/desktop/keybindings/media-keys/window-screenshot "@as []"
dconf write /org/cinnamon/desktop/keybindings/media-keys/window-screenshot-clip "@as []"

# Restart Cinnamon to apply keybindings (equivalent to Ctrl+Alt+Enter)
dbus-send --session --type=method_call --dest=org.Cinnamon /org/Cinnamon org.Cinnamon.RestartCinnamon boolean:false
