# network.nix
{ lib, ... }:
let
  hasModernSamba = lib.versionAtLeast lib.version "24.06";
in
{
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
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
