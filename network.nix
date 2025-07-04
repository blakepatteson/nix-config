{ lib, ... }:
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
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "Samba Server";
        "server role" = "standalone server";
        "map to guest" = "bad user";
        "client min protocol" = "NT1";
        "ntlm auth" = "yes";
        "lanman auth" = "yes";
        "client lanman auth" = "yes";
        "encrypt passwords" = "yes";
        "server min protocol" = "NT1";
        "local master" = "yes";
        "domain master" = "no";
        "preferred master" = "yes";
        "create mask" = "0755";
        "directory mask" = "0755";
        "map archive" = "yes";
        "map system" = "yes";
        "map hidden" = "yes";
      };
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
