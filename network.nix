# network.nix
{ lib, ... }:
let
  hasModernSamba = lib.versionAtLeast lib.version "24.06";
in
{
  networking = {
    hostName = "nixos";
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

      samba-nmbd = {
        wantedBy = lib.mkForce [ ];
        wants = lib.mkForce [ ];
      };

      samba-smbd = {
        wantedBy = lib.mkForce [ ];
        wants = lib.mkForce [ ];
      };

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

  imports = [
    (if hasModernSamba
    then ./samba-configs/samba-modern.nix
    else ./samba-configs/samba-legacy.nix)
  ];

  services.samba = {
    enable = true;
    openFirewall = true;
    shares = {
      development = {
        path = "/home/blake/dev";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0755";
        "directory mask" = "0755";
        "force user" = "blake";
        "valid users" = "blake";
        "inherit permissions" = "yes";
        "inherit acls" = "yes";
        "store dos attributes" = "yes";
      };
    };
  };
}
