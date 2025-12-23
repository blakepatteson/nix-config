{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "emoji-picker" (builtins.readFile ../scripts/user/emoji-picker.sh))
    (writeShellScriptBin "flameshot-screenshot" (builtins.readFile ../scripts/user/flameshot.sh))
    (writeShellScriptBin "mkbox" (builtins.readFile ../scripts/user/mkbox.sh))
    (writeShellScriptBin "mkwindows" (builtins.readFile ../scripts/user/mkwindows.sh))
    (writeShellScriptBin "niri-dev-setup" (builtins.readFile ../scripts/user/niri-dev-setup.sh))
    (writeShellScriptBin "wl-mirror-launcher" (builtins.readFile ../scripts/user/wl-mirror-launcher.sh))

    (makeDesktopItem {
      name = "wl-mirror";
      desktopName = "wl-mirror";
      comment = "Mirrors a wayland output to a window";
      exec = "wl-mirror-launcher";
      icon = "utilities-terminal";
      categories = [ "Utility" ];
      keywords = [ "Mirror" "Output" ];
    })
  ];
}
