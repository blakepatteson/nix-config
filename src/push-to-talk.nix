{ pkgs, ... }:
let
  python = pkgs.python3.withPackages (ps: [ ps.evdev ]);
  pushToTalk = pkgs.writeScript "push-to-talk" ''
    #!${python}/bin/python3
    ${builtins.readFile ../scripts/user/push-to-talk.py}
  '';
in
{
  systemd.user.services.push-to-talk = {
    description = "Forward ` to XWayland as F19 for Discord push-to-talk";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    environment = {
      DISPLAY = ":0";
      XDOTOOL = "${pkgs.xdotool}/bin/xdotool";
      PTT_TRIGGER = "KEY_F2";
      PTT_TARGET = "F19";
    };
    serviceConfig = {
      ExecStart = pushToTalk;
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
