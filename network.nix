{ lib, ... }:
let
  hasModernSamba = lib.versionAtLeast lib.version "24.06";
  _ = builtins.trace "NixOS version: ${lib.version}" null;
  __ = builtins.trace "Has modern Samba: ${toString hasModernSamba}" null;
in
{
  imports = [
    (if hasModernSamba
    then ./samba-configs/samba-modern.nix
    else ./samba-configs/samba-legacy.nix)
  ];

  networking = {
    hostName = "nixos-laptop";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
      # Disable scanning for WiFi networks at boot
      wifi.scanRandMacAddress = false;
    };
    firewall = {
      allowedTCPPorts = [ 3389 631 ]; # CUPS port
      allowedUDPPorts = [ 631 ]; # CUPS port
    };
  };

  systemd = {
    extraConfig = ''
      DefaultTimeoutStartSec=10s
      DefaultTimeoutStopSec=10s
    '';
    services = {
      NetworkManager-wait-online.enable = false;
      systemd-udev-settle.enable = false;
      pmlogger.enable = false;

      systemd-modules-load = {
        serviceConfig = {
          TimeoutStartSec = "2s";
          LogLevelMax = "warning";
        };
      };
    };

    targets.graphical = {
      wants = lib.mkForce [
        "display-manager.service"
        "systemd-update-utmp-runlevel.service"
        "multi-user.target"
      ];
      requires = lib.mkForce [ ];
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
  };
}
